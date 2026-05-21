const dns = require("dns");
dns.setDefaultResultOrder("ipv4first");
dns.setServers(["8.8.8.8", "8.8.4.4"]);

// env config
require("dotenv").config();

// core imports
const express = require("express");
const mongoose = require("mongoose");

// routers
const authRouter = require("./routes/auth");
const employeeRouter = require("./routes/employee");
const adminRouter = require("./routes/admin");
const scheduleRouter = require("./routes/schedule");
const reportRouter = require("./routes/report");
const userProfileRouter = require('./routes/userProfile');


// init
const PORT = process.env.PORT || 3000;
const DB = process.env.DB;
const app = express();

// middleware
app.use(express.json());

// routes
app.use(authRouter);
app.use(employeeRouter);
app.use(adminRouter);
app.use(scheduleRouter);
app.use(reportRouter);
app.use(userProfileRouter);


// static files
app.use("/uploads", express.static("uploads"));

// check DB
if (!DB) {
  console.log("DB connection string missing in .env");
  process.exit(1);
}

// mongo connection
mongoose
  .connect(DB)
  .then(() => {
    console.log("MongoDB connection successful");
  })
  .catch((e) => {
    console.log("MongoDB connection error:", e);
  });

//shutdown
process.on("SIGINT", () => {
  console.log("Shutting down server...");
  process.exit(0);
});

// start server
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running at port ${PORT}`);
});