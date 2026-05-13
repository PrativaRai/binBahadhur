const express = require("express");
const scheduleRouter = express.Router();
const Schedule = require("../models/schedule");
const auth = require("../middleware/auth");
const upload = require("../middleware/upload");

// 1. CREATE SCHEDULE

scheduleRouter.post("/api/schedule", auth, async (req, res) => {
  try {
    const { area, subArea, scheduleType, scheduledDate, scheduledTime } = req.body;

    const schedule = new Schedule({
      userId: req.userId,     
      phone: req.user,  
      status: "pending",      
      area,
      subArea,
      scheduleType,
      scheduledDate,
      scheduledTime,
    });

    await schedule.save();

    res.json({ success: true, msg: "Schedule created successfully", schedule });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// 2. UPDATE SCHEDULE
scheduleRouter.put(
  "/api/schedule/:id",
  auth,
  upload.single("image"),
  async (req, res) => {
    try {
      const { wasteType, description, pricePerKg } = req.body;
      const imageUrl = req.file ? `/uploads/${req.file.filename}` : undefined;

      const schedule = await Schedule.findById(req.params.id);

      if (!schedule) {
        return res.status(404).json({ success: false, msg: "Schedule not found" });
      }

      if (wasteType) schedule.wasteType = wasteType;
      if (description) schedule.description = description;
      if (pricePerKg) schedule.pricePerKg = pricePerKg;
      if (imageUrl) schedule.imageUrl = imageUrl;

      await schedule.save();

      res.json({ success: true, msg: "Schedule updated successfully", schedule });
    } catch (e) {
      res.status(500).json({ success: false, error: e.message });
    }
  }
);

// 3. GET USER'S OWN SCHEDULES

scheduleRouter.get("/api/schedule", auth, async (req, res) => {
  try {
    const schedules = await Schedule.find({ userId: req.user });
    res.json(schedules);
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// 4. GET SCHEDULE BY ID
scheduleRouter.get("/api/schedule/:id", auth, async (req, res) => {
  try {
    const schedule = await Schedule.findById(req.params.id);

    if (!schedule) {
      return res.status(404).json({ success: false, msg: "Schedule not found" });
    }
 
    res.json(schedule);
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});


//start button
scheduleRouter.post("/api/schedule/start/:taskId", auth, async (req, res) => {
    try {
        const { taskId } = req.params;
        const employeeId = req.userId; 

        const task = await Schedule.findByIdAndUpdate(
            taskId,
            { 
                status: 'started',
                assignedTo: employeeId, // Track which employee took the task
                startedAt: new Date() 
            },
            { new: true } 
        ).populate({
            path: 'userId', 
            select: 'name phone' 
        });

        if (!task) {
            return res.status(404).json({ 
                success: false, 
                msg: "Task not found" 
            });
        }

        res.status(200).json({
            success: true,
            message: "Task started successfully",
            task: task 
        });

    } catch (error) {
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});
//accepted
scheduleRouter.post("/api/schedule/accept/:id", auth, async (req, res) => {
  try {
    const schedule = await Schedule.findByIdAndUpdate(
      req.params.id,
      { 
        status: "assigned", 
        assignedTo: req.userId // Save the ID of the employee who clicked accept
      },
      { new: true }
    ).populate("assignedTo", "name phone"); // Populate employee details

    res.json({ success: true, schedule });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});


scheduleRouter.get("/api/user/schedules", auth, async (req, res) => {
  try {
    const schedules = await Schedule.find({ userId: req.userId })
      .populate("assignedTo", "name phone"); // This sends the employee info to the user
    res.json(schedules);
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});





module.exports = scheduleRouter;