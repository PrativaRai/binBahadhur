const dns = require('dns');
dns.setDefaultResultOrder('ipv4first');
dns.setServers(['8.8.8.8', '8.8.4.4']);

require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");

// Routes
const authRouter = require("./routes/auth");
const employeeRouter = require("./routes/employee");
const adminRouter = require("./routes/admin");
const scheduleRouter = require('./routes/schedule');
const reportRouter = require('./routes/report');

const PORT = process.env.PORT || 3000;
const DB = process.env.DB;
const app = express();

app.use(express.json());
app.use(authRouter);
app.use(employeeRouter);
app.use(adminRouter);
app.use(scheduleRouter);
app.use(reportRouter);

if (!DB) {
  console.log("DB connection string missing in .env");
  process.exit(1);
}

mongoose.connect(DB).then(() => {
    console.log('MongoDB connection successful');
}).catch((e) => {
    console.log("MongoDB connection error:", e);
});

// Handle Shutdown
process.on('SIGINT', () => {
    console.log("Shutting down server...");
    process.exit(0);
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server is running at port ${PORT}`);
    console.log(`Check terminal for WhatsApp QR!`);
});