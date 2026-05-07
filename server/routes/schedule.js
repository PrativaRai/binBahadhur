const express = require('express'); 
const scheduleRouter = express.Router();// routes create garxa to handle API
const Schedule = require('../models/schedule');
const auth = require('../middleware/auth'); //login user le matra route access garnu pauxa

// Create a new schedule pickup
scheduleRouter.post('/api/schedule', auth, async (req, res) => {
    try {
        const { area, subArea, scheduleType, scheduledDate, scheduledTime } = req.body;

        const schedule = new Schedule({
            phone: req.user,
            area,
            subArea,
            scheduleType,
            scheduledDate,
            scheduledTime,
        });

        await schedule.save();

        res.json({ msg: 'Schedule created successfully', schedule });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Get all schedules for a user
scheduleRouter.get('/api/schedule', auth, async (req, res) => {
    try {
        const schedules = await Schedule.find({ email: req.user });
        res.json(schedules);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = scheduleRouter;