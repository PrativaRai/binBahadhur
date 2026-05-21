const express = require('express');
const userProfileRouter = express.Router(); 
const User = require('../models/user');
const Schedule = require('../models/schedule');
const auth = require('../middleware/auth');

// Get user profile with task stats
userProfileRouter.get('/api/user-profile/:id', auth, async (req, res) => {
    try {
        // get user details
        const user = await User.findById(req.params.id);
        if (!user) return res.status(404).json({ msg: 'User not found' });

        // count tasks done and incomplete
        const tasksDone = await Schedule.countDocuments({
            phone: user.phone,
            status: 'completed'
        });

        const tasksIncomplete = await Schedule.countDocuments({
            phone: user.phone,
            status: 'pending'
        });

        res.json({
            name: user.name,
            phone: user.phone,
            role: user.type,
            tasksDone,
            tasksIncomplete,
        });

    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = userProfileRouter;