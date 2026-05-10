const express = require("express");
const scheduleRouter = express.Router();
const Schedule = require("../models/schedule");
const auth = require("../middleware/auth");
const upload = require("../middleware/upload");

// 1. CREATE SCHEDULE
// Changed: phone is now set to "unassigned" so workers can find it.
// Added: status is explicitly set to "pending".
// Added: userId stores req.user so we don't lose track of who created the task.
scheduleRouter.post("/api/schedule", auth, async (req, res) => {
  try {
    const { area, subArea, scheduleType, scheduledDate, scheduledTime } = req.body;

    const schedule = new Schedule({
      userId: req.user,       // Store the actual user ID here
      phone: "unassigned",    // Set to "unassigned" for the worker dashboard
      status: "pending",      // Ensure status is pending
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

// 2. UPDATE SCHEDULE (Add details/images)
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
// Changed: Querying by userId instead of phone
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

// // Inside your CREATE SCHEDULE route
// scheduleRouter.post("/api/schedule", auth, async (req, res) => {
//   try {
//     const { area, subArea, scheduleType, scheduledDate, scheduledTime } = req.body;
    
//     // Fetch the logged-in user to get their phone number
//     const user = await User.findById(req.user);

//     const schedule = new Schedule({
//       userId: req.user,
//       phone: user.phone, // Store the actual phone, but it stays hidden via schema
//       status: "pending",
//       area,
//       subArea,
//       scheduleType,
//       scheduledDate,
//       scheduledTime,
//     });

//     await schedule.save();
//     res.json({ success: true, msg: "Created", schedule });
//   } catch (e) {
//     res.status(500).json({ success: false, error: e.message });
//   }
// });

module.exports = scheduleRouter;