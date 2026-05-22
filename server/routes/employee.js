const mongoose = require("mongoose");
const express = require("express");
const employeeRouter = express.Router();
const Schedule = require("../models/schedule");
const User = require("../models/user");
const Complain = require("../models/complain");
const auth = require("../middleware/auth");
const employeeMiddleware = require("../middleware/employee");

// 1. GET ALL AVAILABLE (UNASSIGNED) TASKS

employeeRouter.get(
  "/api/worker/available-tasks",
  auth,
  employeeMiddleware,
  async (req, res) => {
    try {
      const tasks = await Schedule.find({ status: "pending" })
        .populate("userId", "name")
        .sort({ createdAt: -1 });

      res.json({
        success: true,
        count: tasks.length,
        tasks,
      });
    } catch (e) {
      res.status(500).json({ success: false, error: e.message });
    }
  },
);

// 2. ACCEPT A TASK

employeeRouter.patch(
  "/api/worker/accept-task/:taskId",
  auth,
  employeeMiddleware,
  async (req, res) => {
    try {
      const taskId = req.params.taskId;
      const employeeId = req.userId;

      const employee = await User.findById(employeeId);
      if (!employee) {
        return res
          .status(404)
          .json({ success: false, error: "Employee not found" });
      }

      const task = await Schedule.findById(taskId);
      if (!task) {
        return res
          .status(404)
          .json({ success: false, error: "Task not found" });
      }

      if (task.status !== "pending") {
        return res.status(400).json({
          success: false,
          error: "Task already assigned or completed",
        });
      }

      task.status = "assigned";

      task.phone = employee.phone;
      await task.save();

      const revealedTask = await Schedule.findById(taskId).populate({
        path: "userId",
        select: "name +phone",
      });

      if (!revealedTask.userId) {
        return res
          .status(500)
          .json({ success: false, error: "User data not found" });
      }

      res.json({
        success: true,
        message: "Task accepted successfully",
        task: {
          id: revealedTask._id,
          area: revealedTask.area,
          subArea: revealedTask.subArea,
          creatorPhone: revealedTask.userId?.phone || "Not available",
          creatorName: revealedTask.userId?.name || "Unknown",
        },
      });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  },
);

// 3. GET ASSIGNED TASKS (MY TASKS)
employeeRouter.get(
  "/api/worker/my-tasks",
  auth,
  employeeMiddleware,
  async (req, res) => {
    try {
      const employee = await User.findById(req.userId);

      const tasks = await Schedule.find({
        phone: employee.phone,
        status: { $in: ["assigned", "started", "in-progress"] },
      })
        .populate({
          path: "userId",
          select: "name +phone",
        })
        .sort({ createdAt: -1 });

      res.json({ success: true, count: tasks.length, tasks });
    } catch (e) {
      res.status(500).json({ success: false, error: e.message });
    }
  },
);

// 4. ADD COMPLAIN
employeeRouter.post(
  "/api/worker/add-complain",
  auth,
  employeeMiddleware,
  async (req, res) => {
    try {
      const { phoneNumber, description } = req.body;
      const employeeUser = await User.findById(req.userId);

      let complain = new Complain({
        phoneNumber,
        description,
        employee: employeeUser.name,
        userId: req.userId,
      });

      await complain.save();

      res.json({
        success: true,
        msg: "Complain registered successfully",
        complain,
      });
    } catch (e) {
      res.status(500).json({ success: false, error: e.message });
    }
  },
);

// GET /api/profile/:id
employeeRouter.get("/api/profile/:id", async (req, res) => {
  try {
    const userId = req.params.id;

    const profileData = await User.aggregate([
      { $match: { _id: new mongoose.Types.ObjectId(userId) } },

      {
        $lookup: {
          from: "schedules",
          localField: "phone",
          foreignField: "phone",
          as: "allTasks",
        },
      },
      {
        $project: {
          name: 1,
          phone: 1,
          role: "$type",
          profilePic: 1,
          tasksTaken: { $size: "$allTasks" },
          tasksCompleted: {
            $size: {
              $filter: {
                input: "$allTasks",
                as: "t",
                cond: { $eq: ["$$t.status", "completed"] },
              },
            },
          },
        },
      },
    ]);

    res.json(profileData[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 6. COMPLETE A TASK
employeeRouter.post(
  "/api/worker/complete-task",
  auth,
  employeeMiddleware,
  async (req, res) => {
    try {
      const { taskId, weightCollected, moneyPaid } = req.body;

      const task = await Schedule.findById(taskId);
      if (!task) {
        return res
          .status(404)
          .json({ success: false, error: "Task not found" });
      }

      // Update task details
      const weight = Number(weightCollected);
      task.status = "completed";
      task.weightCollected = weightCollected; // Ensure these fields exist in your Schedule model
      task.moneyPaid = moneyPaid;
      task.completedAt = Date.now();

      await task.save();
      const user = await User.findById(task.userId);

      user.points = (user.points || 0) + weight;

      await user.save();

      res.json({
        success: true,
        message: "Task completed successfully",
        task,
      });
    } catch (e) {
      res.status(500).json({ success: false, error: e.message });
    }
  },
);

module.exports = employeeRouter;
