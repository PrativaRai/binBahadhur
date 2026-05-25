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
  },);

//complain
employeeRouter.post(
  "/api/worker/add-complain",
  employeeMiddleware,
  async (req, res) => {
    try {
      const { phoneNumber, description, employee } = req.body;

      // FIXED: Search for the phone number AND ensure the account type is strictly 'user'
      const targetCustomer = await User.findOne({ 
        phone: phoneNumber, 
        type: "user" 
      });

      // If the number belongs to an employee (or doesn't exist), targetCustomer will be null
      if (!targetCustomer) {
        return res.status(404).json({ 
          success: false, 
          msg: "No customer account found with this phone number." 
        });
      }

      let complain = new Complain({
        phoneNumber,               
        description,
        employee: employee,        
        userId: targetCustomer._id, 
      });

      await complain.save();

      res.json({
        success: true,
        msg: `Complaint against ${targetCustomer.name} registered successfully`,
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
      const weight = Number(weightCollected) || 0;
      task.status = "completed";
      task.weightCollected = weightCollected; // Ensure these fields exist in your Schedule model
      task.moneyPaid = moneyPaid;
      task.completedAt = Date.now();

      await task.save();
      const user = await User.findById(task.userId);

      const currentPoints = Number(user.points) || 0;
      user.points = currentPoints + weight;

      await user.save();

      res.json({
        success: true,
        message: "Task completed successfully",
        task,
        updatedUserPoints: user.points,
      });
    } catch (e) {
      res.status(500).json({ success: false, error: e.message });
    }
  },
);

module.exports = employeeRouter;
