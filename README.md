# BusSync - Real-Time College Bus Seat Availability System

> **"Check. Choose. Board."**

BusSync is a real-time college bus seat availability tracking application designed for college campuses. It enables students to view real-time seat availability, parking locations, and served stops, preventing students from walking to full buses when alternative buses serving their destination have empty seats.

---

## 🚀 Key Features

### 🚌 Passenger Capabilities
- **Destination Search & Selection**: Autocomplete search across predefined college bus stops (e.g. *Panruti*, *Pannur*, *Pallavaram*, *Tambaram*, *Guindy*, *Chengalpattu*).
- **Real-Time Seat Availability**: Automatically sorts buses by highest available seats first.
- **Data Freshness Indicators**:
  - `LIVE` (0 - 5 minutes old)
  - `RECENTLY UPDATED` (5 - 15 minutes old)
  - `STALE` (> 15 minutes old) with warning banners advising physical verification.
- **Bus Details Screen**: Complete breakdown of capacity, students boarded, seat progress bar, parking location, and served stops.
- **Instant Sync**: Real-time Socket.IO synchronization updates seat counts without manual pull-to-refresh.

### 👨‍✈️ Driver Capabilities
- **Extremely Simple Interface**: Quick `[-] N [+]` counter buttons for students boarded.
- **Automatic Seat Calculation**: `Available Seats = Capacity - Students Boarded` (never negative).
- **Predefined Parking Locations**: Select from *Engineering Ground*, *Inside Tech Gate*, or *Outside Engineering Gate*.
- **Predefined Stop Management**: Search, filter, and multi-select stops served on the trip.
- **Stale Data Reminder**: Warning notification if bus data hasn't been updated for > 15 minutes.

### 🔑 Admin Capabilities
- Admin dashboard to review all registered buses, driver assignments, capacity limits, and system status.

---

## 🛠️ Technology Stack

- **Frontend**: Flutter (Material 3, Android target)
- **State Management**: Provider (`AuthProvider`, `PassengerProvider`, `DriverProvider`)
- **Backend API**: Node.js + Express
- **Database**: SQLite (`bussync.db`)
- **Real-Time Engine**: Socket.IO (`socket.io` & `socket_io_client`)
- **Authentication**: JWT & bcrypt password hashing

---

## 📁 Project Structure

```
bussync/
├── backend/                  # Node.js + Express + SQLite Backend API
│   ├── server.js             # REST API & Socket.IO Real-time server
│   ├── database.js           # SQLite schema creation & seed script
│   ├── bussync.db            # SQLite relational database
│   └── package.json
├── assets/
│   └── images/
│       ├── logo.png          # Official BusSync branding asset
│       └── logo.jpg
├── lib/
│   ├── main.dart             # Application entry point with MultiProvider & Theme
│   ├── core/
│   ├── models/               # UserModel, BusModel, StopModel, ParkingLocationModel
│   ├── services/             # ApiService & SocketService
│   ├── providers/            # AuthProvider, PassengerProvider, DriverProvider
│   ├── screens/
│   │   ├── home/             # Landing screen with role selection
│   │   ├── auth/             # Passenger and Driver login screens
│   │   ├── passenger/        # Destination selection, Available buses, Bus details
│   │   ├── driver/           # Driver dashboard with [-] N [+] counter
│   │   └── admin/            # Admin console
│   └── widgets/              # BusCard, StatusBadge, FreshnessBadge, StaleWarningBanner
├── test/
│   ├── bus_logic_test.dart   # Domain logic unit tests
│   └── widget_test.dart      # Flutter smoke tests
└── pubspec.yaml
```

---

## 🔑 Demo Credentials

| Role | Email | Password | Assigned Bus |
| :--- | :--- | :--- | :--- |
| **Driver 1** | `driver21g@bussync.edu` | `driver123` | Bus 21G (Cap: 40) |
| **Driver 2** | `driver18@bussync.edu` | `driver123` | Bus 18 (Cap: 35) |
| **Driver 3** | `driver570@bussync.edu` | `driver123` | Bus 570 (Cap: 45) |
| **Passenger** | `passenger@bussync.edu` | `pass123` | N/A |
| **Admin** | `admin@bussync.edu` | `admin123` | All System Data |

*Note: Guest passengers can also browse without signing in.*

---

## 💻 How to Run Locally

### 1. Start Backend Server
```bash
cd backend
npm install
npm start
```
The backend server runs on `http://localhost:3000` (or `http://10.0.2.2:3000` for Android Emulator).

### 2. Run Flutter App on Android Emulator
```bash
# Verify attached devices or emulator
flutter devices

# Launch Android App
flutter run -d <emulator-id>
```

---

## 🧪 Running Unit Tests

```bash
flutter test
```

Tests verify:
1. Available seat calculation (`Capacity - Boarded`)
2. Capacity limit validation (`0 <= Boarded <= Capacity`)
3. Data freshness calculations (`LIVE`, `RECENTLY UPDATED`, `STALE`)
4. Bus status categorization (`AVAILABLE`, `ALMOST_FULL`, `FULL`, `STALE`)
5. Sorting algorithm (highest seats first, tie-breaking by timestamp)
