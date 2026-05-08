const dns = require("dns");
dns.setDefaultResultOrder("ipv4first");
dns.setServers(["8.8.8.8", "8.8.4.4"]);

<<<<<<< HEAD
require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");

// Routes
=======
//Imports contain garxa packages ko
require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const jwt = require("jsonwebtoken");

//Import other files

>>>>>>> d0ea1fdf55e5284baa4050f0f2a199c9050f0096
const authRouter = require("./routes/auth");
const employeeRouter = require("./routes/employee");
const adminRouter = require("./routes/admin");
const scheduleRouter = require("./routes/schedule");
const reportRouter = require("./routes/report");

<<<<<<< HEAD
=======
//init
>>>>>>> d0ea1fdf55e5284baa4050f0f2a199c9050f0096
const PORT = process.env.PORT || 3000;
const DB = process.env.DB;
const app = express();

<<<<<<< HEAD
=======
//middleware
>>>>>>> d0ea1fdf55e5284baa4050f0f2a199c9050f0096
app.use(express.json());
app.use(authRouter);
app.use(employeeRouter);
app.use(adminRouter);
app.use(scheduleRouter);

//static files uploads(images)
app.use("/uploads", express.static("uploads"));

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

<<<<<<< HEAD
// Handle Shutdown
process.on('SIGINT', () => {
    console.log("Shutting down server...");
    process.exit(0);
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server is running at port ${PORT}`);
    console.log(`Check terminal for WhatsApp QR!`);
});
=======
mongoose
  .connect(DB)
  .then(() => {
    console.log("connection successful");
  })
  .catch((e) => {
    console.log(e);
  });

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running at port ${PORT}`);
});
>>>>>>> d0ea1fdf55e5284baa4050f0f2a199c9050f0096
