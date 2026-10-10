const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const bcrypt = require('bcryptjs');

const dbPath = path.resolve(__dirname, 'bussync.db');
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  // 1. Users table
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL,
      name TEXT NOT NULL
    )
  `);

  // 2. Parking Locations table
  db.run(`
    CREATE TABLE IF NOT EXISTS parking_locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE NOT NULL
    )
  `);

  // 3. Stops table
  db.run(`
    CREATE TABLE IF NOT EXISTS stops (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE NOT NULL
    )
  `);

  // 4. Buses table
  db.run(`
    CREATE TABLE IF NOT EXISTS buses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bus_number TEXT UNIQUE NOT NULL,
      capacity INTEGER NOT NULL,
      driver_id INTEGER UNIQUE,
      parking_location_id INTEGER,
      students_boarded INTEGER DEFAULT 0,
      last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(driver_id) REFERENCES users(id),
      FOREIGN KEY(parking_location_id) REFERENCES parking_locations(id)
    )
  `);

  // 5. Bus Stops mapping table
  db.run(`
    CREATE TABLE IF NOT EXISTS bus_stops (
      bus_id INTEGER NOT NULL,
      stop_id INTEGER NOT NULL,
      PRIMARY KEY (bus_id, stop_id),
      FOREIGN KEY(bus_id) REFERENCES buses(id) ON DELETE CASCADE,
      FOREIGN KEY(stop_id) REFERENCES stops(id) ON DELETE CASCADE
    )
  `);

  // 6. Reservations table
  db.run(`
    CREATE TABLE IF NOT EXISTS reservations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bus_id INTEGER NOT NULL,
      seats_reserved INTEGER NOT NULL,
      status TEXT DEFAULT 'ACTIVE',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(bus_id) REFERENCES buses(id) ON DELETE CASCADE
    )
  `);

  seedInitialData();
});

function seedInitialData() {
  const hashedPasswordDriver = bcrypt.hashSync('driver123', 10);
  const hashedPasswordPass = bcrypt.hashSync('pass123', 10);
  const hashedPasswordAdmin = bcrypt.hashSync('admin123', 10);

  // Seed Users
  const users = [
    ['driver21g@bussync.edu', hashedPasswordDriver, 'DRIVER', 'Driver 21G'],
    ['driver18@bussync.edu', hashedPasswordDriver, 'DRIVER', 'Driver 18'],
    ['driver570@bussync.edu', hashedPasswordDriver, 'DRIVER', 'Driver 570'],
    ['passenger@bussync.edu', hashedPasswordPass, 'PASSENGER', 'Student Alex'],
    ['admin@bussync.edu', hashedPasswordAdmin, 'ADMIN', 'Admin User']
  ];

  const userStmt = db.prepare(`INSERT OR IGNORE INTO users (email, password, role, name) VALUES (?, ?, ?, ?)`);
  users.forEach(u => userStmt.run(u));
  userStmt.finalize();

  // Seed Parking Locations (5 predefined locations)
  const parkingLocations = [
    'Engineering Ground',
    'Inside Tech Gate',
    'Outside Engineering Gate',
    'Tech Bus Bay',
    'Next to Arch'
  ];
  const parkStmt = db.prepare(`INSERT OR IGNORE INTO parking_locations (name) VALUES (?)`);
  parkingLocations.forEach(p => parkStmt.run(p));
  parkStmt.finalize();

  // Seed Stops
  const stops = [
    'Panruti',
    'Pannur',
    'Pallavaram',
    'Chengalpattu',
    'Tambaram',
    'Guindy',
    'Sriperumbudur',
    'Kanchipuram',
    'Vandalur',
    'Chromepet'
  ];
  const stopStmt = db.prepare(`INSERT OR IGNORE INTO stops (name) VALUES (?)`);
  stops.forEach(s => stopStmt.run(s));
  stopStmt.finalize();

  // Seed Buses & Mappings after short timeout to let IDs resolve
  setTimeout(() => {
    db.all(`SELECT id, email FROM users WHERE role='DRIVER'`, (err, driverRows) => {
      if (err || !driverRows) return;
      const driverMap = {};
      driverRows.forEach(d => { driverMap[d.email] = d.id; });

      db.all(`SELECT id, name FROM parking_locations`, (err, parkRows) => {
        if (err || !parkRows) return;
        const parkMap = {};
        parkRows.forEach(p => { parkMap[p.name] = p.id; });

        const now = new Date();
        const twoMinsAgo = new Date(now.getTime() - 2 * 60 * 1000).toISOString();
        const fourMinsAgo = new Date(now.getTime() - 4 * 60 * 1000).toISOString();
        const oneMinAgo = new Date(now.getTime() - 1 * 60 * 1000).toISOString();

        const buses = [
          ['Bus 21G', 40, driverMap['driver21g@bussync.edu'], parkMap['Engineering Ground'], 0, twoMinsAgo],
          ['Bus 18', 35, driverMap['driver18@bussync.edu'], parkMap['Inside Tech Gate'], 0, fourMinsAgo],
          ['Bus 570', 45, driverMap['driver570@bussync.edu'], parkMap['Outside Engineering Gate'], 0, oneMinAgo]
        ];

        const busStmt = db.prepare(`
          INSERT OR IGNORE INTO buses (bus_number, capacity, driver_id, parking_location_id, students_boarded, last_updated)
          VALUES (?, ?, ?, ?, ?, ?)
        `);
        buses.forEach(b => busStmt.run(b));
        busStmt.finalize();

        // Seed Bus Stops mapping
        setTimeout(() => {
          db.all(`SELECT id, bus_number FROM buses`, (err, busRows) => {
            if (err || !busRows) return;
            const bMap = {};
            busRows.forEach(b => { bMap[b.bus_number] = b.id; });

            db.all(`SELECT id, name FROM stops`, (err, sRows) => {
              if (err || !sRows) return;
              const sMap = {};
              sRows.forEach(s => { sMap[s.name] = s.id; });

              const mappings = [
                // Bus 21G
                [bMap['Bus 21G'], sMap['Panruti']],
                [bMap['Bus 21G'], sMap['Pannur']],
                [bMap['Bus 21G'], sMap['Pallavaram']],
                [bMap['Bus 21G'], sMap['Guindy']],
                // Bus 18
                [bMap['Bus 18'], sMap['Panruti']],
                [bMap['Bus 18'], sMap['Tambaram']],
                [bMap['Bus 18'], sMap['Vandalur']],
                // Bus 570
                [bMap['Bus 570'], sMap['Panruti']],
                [bMap['Bus 570'], sMap['Chengalpattu']],
                [bMap['Bus 570'], sMap['Chromepet']],
                [bMap['Bus 570'], sMap['Sriperumbudur']]
              ];

              const mapStmt = db.prepare(`INSERT OR IGNORE INTO bus_stops (bus_id, stop_id) VALUES (?, ?)`);
              mappings.forEach(m => {
                if (m[0] && m[1]) mapStmt.run(m);
              });
              mapStmt.finalize();
            });
          });
        }, 500);
      });
    });
  }, 500);
}

module.exports = db;
