const express = require("express");
const userNotificationRouter = express.Router();
const Schedule = require("../models/schedule");
const User = require("../models/user");
const auth = require("../middleware/auth");
const mongoose = require("mongoose");

// 1. GET MY REQUESTS
userNotificationRouter.get("/my-requests", auth, async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.userId);

    // Since items are hard-deleted on swipe, you don't strictly need the $nin check anymore,
    // but leaving a standard query looking up user's active schedules keeps things bulletproof.
    const tasks = await Schedule.find({ userId: userId }).sort({ createdAt: -1 });

    const processedTasks = await Promise.all(
      tasks.map(async (task) => {
        let employeeDetails = null;
        const status = (task.status || "").toLowerCase();

        if (task.phone && status !== "pending") {
          const worker = await User.findOne({ phone: task.phone }).select(
            "name phone profilePic"
          );

          employeeDetails = worker
            ? {
                name: worker.name,
                phone: worker.phone,
                profilePic: worker.profilePic || ""
              }
            : {
                name: `Professional (${task.phone})`,
                phone: task.phone,
                profilePic: ""
              };
        }

        return {
          _id: task._id,
          area: task.area,
          subArea: task.subArea,
          status: task.status,
          createdAt: task.createdAt,
          weightCollected: task.weightCollected || 0,
          moneyPaid: task.moneyPaid || 0,
          assignedTo: employeeDetails
        };
      })
    );

    res.json({
      success: true,
      count: processedTasks.length,
      tasks: processedTasks
    });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// 2. DELETE A NOTIFICATION PERMANENTLY FROM THE DATABASE (TRIGGERED ON SWIPE)
userNotificationRouter.delete(
  "/dismiss-request/:id",
  auth,
  async (req, res) => {
    try {
      const { id } = req.params;

      // This thoroughly wipes out the document record from MongoDB
      const deletedSchedule = await Schedule.findByIdAndDelete(id);

      if (!deletedSchedule) {
        return res.status(404).json({ success: false, error: "Request not found" });
      }

      res.json({ success: true, message: "Notification deleted from database permanently" });
    } catch (e) {
      res.status(500).json({ success: false, error: e.message });
    }
  }
);

module.exports = userNotificationRouter;