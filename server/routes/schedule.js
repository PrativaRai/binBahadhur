const express = require("express");
const scheduleRouter = express.Router();
const Schedule = require("../models/schedule");
const auth = require("../middleware/auth");
const upload = require("../middleware/upload");

// Create schedule
scheduleRouter.post("/api/schedule", auth, async (req, res) => {
  try {
    const { area, subArea, scheduleType, scheduledDate, scheduledTime } =
      req.body;

    const schedule = new Schedule({
      phone: req.user,
      area,
      subArea,
      scheduleType,
      scheduledDate,
      scheduledTime,
    });

    await schedule.save();

    res.json({ msg: "Schedule created successfully", schedule });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Update schedule details pachhi description ra waste type ani image add garna milos vanera
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
        return res.status(404).json({ msg: "Schedule not found" });
      }

      if (wasteType) schedule.wasteType = wasteType;
      if (description) schedule.description = description;
      if (pricePerKg) schedule.pricePerKg = pricePerKg;
      if (imageUrl) schedule.imageUrl = imageUrl;

      await schedule.save();

      res.json({ msg: "Schedule updated successfully", schedule });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  },
);

// Get all schedules for user
scheduleRouter.get("/api/schedule", auth, async (req, res) => {
  try {
    const schedules = await Schedule.find({ phone: req.user });
    res.json(schedules);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get schedule by ID confirmation page ma schedule ko details haru dekhauxa vanera
scheduleRouter.get("/api/schedule/:id", auth, async (req, res) => {
  try {
    const schedule = await Schedule.findById(req.params.id);

    if (!schedule) {
      return res.status(404).json({ msg: "Schedule not found" });
    }

    res.json(schedule);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = scheduleRouter;
