const express = require("express");
const employeeRouter = express.Router();
const Schedule = require("../models/schedule");
const User = require("../models/user");
const Complain = require("../models/complain");
const auth = require("../middleware/auth");
const employeeMiddleware = require("../middleware/employee");

// 1. GET ALL AVAILABLE (UNASSIGNED) TASKS
// Hides phone numbers from the general list
employeeRouter.get("/api/worker/available-tasks", auth, employeeMiddleware, async (req, res) => {
  try {
    // Only fetch tasks that are 'pending'
    // Do NOT select phone or populate phone here
    const tasks = await Schedule.find({ status: "pending" })
      .populate("userId", "name") 
      .sort({ createdAt: -1 });

    res.json({ 
      success: true, 
      count: tasks.length, 
      tasks 
    });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// 2. ACCEPT A TASK
// Reveals the phone number only at the moment of acceptance
employeeRouter.patch("/api/worker/accept-task/:taskId", auth, employeeMiddleware, async (req, res) => {
  try {
    const taskId = req.params.taskId;
    const employeeId = req.userId;

    const employee = await User.findById(employeeId);
    if (!employee) {
      return res.status(404).json({ success: false, error: "Employee not found" });
    }

    const task = await Schedule.findById(taskId);
    if (!task) {
      return res.status(404).json({ success: false, error: "Task not found" });
    }
    
    // Check status instead of the phone string
    if (task.status !== "pending") {
      return res.status(400).json({ success: false, error: "Task already assigned or completed" });
    }

    // Assign employee and update status
    task.status = "assigned";
    // We store the employee's phone here so we know who is doing the job
    task.phone = employee.phone; 
    await task.save();

    // Now reveal the creator's phone number using '+phone' 
    // This override is necessary because of 'select: false' in the Schema
    const revealedTask = await Schedule.findById(taskId).populate({
      path: 'userId',
      select: 'name +phone' 
    });
    // Check if the populate actually worked
if (!revealedTask.userId) {
    return res.status(500).json({ success: false, error: "User data not found" });
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
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 3. GET ASSIGNED TASKS (MY TASKS)
// Re-shows phone numbers for tasks the employee owns
employeeRouter.get("/api/worker/my-tasks", auth, employeeMiddleware, async (req, res) => {
  try {
    const employee = await User.findById(req.userId);
    
    // Find tasks assigned to this employee's phone number
    const tasks = await Schedule.find({
      phone: employee.phone,
      status: "assigned"
    }).populate({
      path: 'userId',
      select: 'name +phone' // Must explicitly ask for phone here too
    }).sort({ createdAt: -1 });

    res.json({ success: true, count: tasks.length, tasks });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// 4. ADD COMPLAIN
employeeRouter.post('/api/worker/add-complain', auth, employeeMiddleware, async (req, res) => {
  try {
    const { phoneNumber, description } = req.body;
    const employeeUser = await User.findById(req.userId);

    let complain = new Complain({
      phoneNumber,
      description,
      employee: employeeUser.name,
      userId: req.userId 
    });

    await complain.save();
    
    res.json({
      success: true,
      msg: "Complain registered successfully",
      complain
    });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

module.exports = employeeRouter;