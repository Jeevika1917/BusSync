const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const db = require('./database');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE']
  }
});

const JWT_SECRET = 'bussync_super_secret_jwt_key_2026';

app.use(cors());
app.use(express.json());

// --- Authentication Middleware ---
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Access token required' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid or expired token' });
    req.user = user;
    next();
  });
}

function requireRole(role) {
  return (req, res, next) => {
    if (!req.user || req.user.role !== role) {
      return res.status(403).json({ error: `Access denied. Requires ${role} role.` });
    }
    next();
  };
}

// Helper to fetch complete bus object with stops and parking location
function fetchBusById(busId, callback) {
  const query = `
    SELECT 
      b.id,
      b.bus_number,
      b.capacity,
      b.students_boarded,
      COALESCE((SELECT SUM(seats_reserved) FROM reservations WHERE bus_id = b.id AND status = 'ACTIVE'), 0) as reserved_seats,
      MAX(0, (b.capacity - COALESCE((SELECT SUM(seats_reserved) FROM reservations WHERE bus_id = b.id AND status = 'ACTIVE'), 0))) as available_seats,
      b.last_updated,
      b.driver_id,
      u.name as driver_name,
      b.parking_location_id,
      pl.name as parking_location
    FROM buses b
    LEFT JOIN users u ON b.driver_id = u.id
    LEFT JOIN parking_locations pl ON b.parking_location_id = pl.id
    WHERE b.id = ?
  `;

  db.get(query, [busId], (err, bus) => {
    if (err || !bus) return callback(err || new Error('Bus not found'), null);

    const stopsQuery = `
      SELECT s.id, s.name 
      FROM stops s
      JOIN bus_stops bs ON s.id = bs.stop_id
      WHERE bs.bus_id = ?
      ORDER BY s.name ASC
    `;

    db.all(stopsQuery, [busId], (err, stops) => {
      if (err) stops = [];
      bus.stops = stops;
      callback(null, bus);
    });
  });
}

// Helper to fetch all buses (optionally filtered by stopId)
function fetchAllBuses(stopId, callback) {
  let query = `
    SELECT DISTINCT
      b.id,
      b.bus_number,
      b.capacity,
      b.students_boarded,
      COALESCE((SELECT SUM(seats_reserved) FROM reservations WHERE bus_id = b.id AND status = 'ACTIVE'), 0) as reserved_seats,
      MAX(0, (b.capacity - COALESCE((SELECT SUM(seats_reserved) FROM reservations WHERE bus_id = b.id AND status = 'ACTIVE'), 0))) as available_seats,
      b.last_updated,
      b.driver_id,
      u.name as driver_name,
      b.parking_location_id,
      pl.name as parking_location
    FROM buses b
    LEFT JOIN users u ON b.driver_id = u.id
    LEFT JOIN parking_locations pl ON b.parking_location_id = pl.id
  `;

  let params = [];
  if (stopId) {
    query += ` JOIN bus_stops bs ON b.id = bs.bus_id WHERE bs.stop_id = ? `;
    params.push(stopId);
  }

  query += ` ORDER BY available_seats DESC, b.last_updated DESC `;

  db.all(query, params, (err, busRows) => {
    if (err) return callback(err, null);
    if (busRows.length === 0) return callback(null, []);

    let completed = 0;
    busRows.forEach(bus => {
      const stopsQuery = `
        SELECT s.id, s.name 
        FROM stops s
        JOIN bus_stops bs ON s.id = bs.stop_id
        WHERE bs.bus_id = ?
        ORDER BY s.name ASC
      `;
      db.all(stopsQuery, [bus.id], (err, stops) => {
        bus.stops = stops || [];
        completed++;
        if (completed === busRows.length) {
          callback(null, busRows);
        }
      });
    });
  });
}

// --- AUTH ROUTES ---

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  db.get('SELECT * FROM users WHERE email = ?', [email.trim().toLowerCase()], (err, user) => {
    if (err || !user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const passwordIsValid = bcrypt.compareSync(password, user.password);
    if (!passwordIsValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role, name: user.name },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        name: user.name
      }
    });
  });
});

app.get('/api/auth/me', authenticateToken, (req, res) => {
  res.json({ user: req.user });
});

// --- PUBLIC / PASSENGER ROUTES ---

// Get all predefined stops
app.get('/api/stops', (req, res) => {
  db.all('SELECT id, name FROM stops ORDER BY name ASC', [], (err, rows) => {
    if (err) return res.status(500).json({ error: 'Database error' });
    res.json(rows);
  });
});

// Get all predefined parking locations
app.get('/api/parking-locations', (req, res) => {
  db.all('SELECT id, name FROM parking_locations ORDER BY name ASC', [], (err, rows) => {
    if (err) return res.status(500).json({ error: 'Database error' });
    res.json(rows);
  });
});

// Get buses (optional ?stopId=X)
app.get('/api/buses', (req, res) => {
  const stopId = req.query.stopId ? parseInt(req.query.stopId) : null;
  fetchAllBuses(stopId, (err, buses) => {
    if (err) return res.status(500).json({ error: 'Error fetching buses' });
    res.json(buses);
  });
});

// Get single bus details
app.get('/api/buses/:id', (req, res) => {
  const busId = parseInt(req.params.id);
  fetchBusById(busId, (err, bus) => {
    if (err || !bus) return res.status(404).json({ error: 'Bus not found' });
    res.json(bus);
  });
});

// Create anonymous seat reservation for a bus
app.post('/api/buses/:id/reservations', (req, res) => {
  const busId = parseInt(req.params.id);
  const { seats } = req.body;

  const seatsInt = parseInt(seats);
  if (isNaN(seatsInt) || seatsInt <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid seat count'
    });
  }

  // Atomic reservation check and creation
  db.serialize(() => {
    db.get(
      `SELECT 
        b.id,
        b.capacity,
        COALESCE((SELECT SUM(seats_reserved) FROM reservations WHERE bus_id = b.id AND status = 'ACTIVE'), 0) as reserved_seats
       FROM buses b
       WHERE b.id = ?`,
      [busId],
      (err, bus) => {
        if (err || !bus) {
          return res.status(404).json({
            success: false,
            message: 'Bus not found'
          });
        }

        const currentReserved = bus.reserved_seats;
        const availableSeats = bus.capacity - currentReserved;

        if (seatsInt > availableSeats) {
          return res.status(400).json({
            success: false,
            message: 'Not enough seats available'
          });
        }

        // Insert reservation
        db.run(
          `INSERT INTO reservations (bus_id, seats_reserved, status) VALUES (?, ?, 'ACTIVE')`,
          [busId, seatsInt],
          function (err) {
            if (err) {
              return res.status(500).json({
                success: false,
                message: 'Failed to create reservation'
              });
            }

            const reservationId = this.lastID;

            fetchBusById(busId, (err, updatedBus) => {
              if (err || !updatedBus) {
                return res.status(500).json({
                  success: false,
                  message: 'Error fetching updated bus'
                });
              }

              // Emit Socket.IO event to all clients
              io.emit('bus_updated', updatedBus);

              res.json({
                success: true,
                reservation: {
                  id: reservationId,
                  bus_id: busId,
                  seats_reserved: seatsInt
                },
                bus: updatedBus
              });
            });
          }
        );
      }
    );
  });
});

// --- DRIVER ROUTES ---

// Get assigned bus for logged-in driver
app.get('/api/driver/bus', authenticateToken, requireRole('DRIVER'), (req, res) => {
  const driverId = req.user.id;
  db.get('SELECT id FROM buses WHERE driver_id = ?', [driverId], (err, row) => {
    if (err || !row) {
      return res.status(404).json({ error: 'No bus assigned to this driver' });
    }
    fetchBusById(row.id, (err, bus) => {
      if (err) return res.status(500).json({ error: 'Error fetching assigned bus' });
      res.json(bus);
    });
  });
});

// Update assigned bus information (parking location & stops only)
app.put('/api/driver/bus', authenticateToken, requireRole('DRIVER'), (req, res) => {
  const driverId = req.user.id;
  const { parking_location_id, stop_ids } = req.body;

  db.get('SELECT id FROM buses WHERE driver_id = ?', [driverId], (err, bus) => {
    if (err || !bus) {
      return res.status(404).json({ error: 'No bus assigned to this driver' });
    }

    const busId = bus.id;
    const nowIso = new Date().toISOString();

    db.run(
      `UPDATE buses SET parking_location_id = ?, last_updated = ? WHERE id = ?`,
      [parking_location_id || null, nowIso, busId],
      function (err) {
        if (err) return res.status(500).json({ error: 'Failed to update bus details' });

        // Update stop mappings if provided
        if (Array.isArray(stop_ids)) {
          db.run(`DELETE FROM bus_stops WHERE bus_id = ?`, [busId], (err) => {
            if (err) console.error('Error deleting old stops:', err);

            if (stop_ids.length > 0) {
              const stmt = db.prepare(`INSERT OR IGNORE INTO bus_stops (bus_id, stop_id) VALUES (?, ?)`);
              stop_ids.forEach(sId => stmt.run([busId, sId]));
              stmt.finalize();
            }

            broadcastUpdatedBus(busId, res);
          });
        } else {
          broadcastUpdatedBus(busId, res);
        }
      }
    );
  });
});

function broadcastUpdatedBus(busId, res) {
  fetchBusById(busId, (err, updatedBus) => {
    if (err) return res.status(500).json({ error: 'Error fetching updated bus' });

    // Emit Socket.IO event to all clients
    io.emit('bus_updated', updatedBus);

    res.json({
      message: 'Bus information updated successfully',
      bus: updatedBus
    });
  });
}

// --- ADMIN ROUTES ---

app.get('/api/admin/buses', authenticateToken, requireRole('ADMIN'), (req, res) => {
  fetchAllBuses(null, (err, buses) => {
    if (err) return res.status(500).json({ error: 'Database error' });
    res.json(buses);
  });
});

app.post('/api/admin/buses', authenticateToken, requireRole('ADMIN'), (req, res) => {
  const { bus_number, capacity, driver_id, parking_location_id } = req.body;
  if (!bus_number || !capacity) {
    return res.status(400).json({ error: 'Bus number and capacity are required' });
  }

  const nowIso = new Date().toISOString();
  db.run(
    `INSERT INTO buses (bus_number, capacity, driver_id, parking_location_id, last_updated) VALUES (?, ?, ?, ?, ?)`,
    [bus_number, capacity, driver_id || null, parking_location_id || null, nowIso],
    function (err) {
      if (err) return res.status(400).json({ error: 'Bus number already exists or invalid driver ID' });
      fetchBusById(this.lastID, (err, newBus) => {
        io.emit('bus_updated', newBus);
        res.status(201).json(newBus);
      });
    }
  );
});

// Socket.IO Connection Handler
io.on('connection', (socket) => {
  console.log('Socket client connected:', socket.id);
  socket.on('disconnect', () => {
    console.log('Socket client disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`BusSync Server running on http://0.0.0.0:${PORT}`);
});
