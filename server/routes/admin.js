const express = require('express');
const adminRouter = express.Router();
const Complain = require("../models/complain");
const User = require("../models/user"); 
const Schedule = require("../models/schedule");
const adminMiddleware = require("../middleware/admin");

//GET ALL COMPLAINTS
adminRouter.get('/admin/get-complain', adminMiddleware, async (req, res) => {
    try {
        const complain = await Complain.find({}).sort({ createdAt: -1 });
        res.json({ success: true, complaints: complain });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

//RESOLVE / DELETE COMPLAINT
adminRouter.post('/admin/delete-complain', adminMiddleware, async (req, res) => {
    try {
        const { id } = req.body;
        let complain = await Complain.findByIdAndDelete(id);
        res.json(complain);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// UPDATE USER STATUS (SUSPEND/ACTIVATE)
adminRouter.post("/admin/update-user-status", adminMiddleware, async (req, res) => {
    try {
        
        const { phoneNumber, targetStatus } = req.body;

        
        const user = await User.findOneAndUpdate(
            { phone: phoneNumber }, 
            { status: targetStatus },
            { returnDocument: 'after' } 
        );

        if (!user) {
           
            return res.status(400).json({ msg: "User with this phone number not found!" });
        }

        res.json(user);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

//profile admin
adminRouter.get("/api/profile/:id", adminMiddleware, async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        
        if (!user) {
            return res.status(404).json({ error: "Admin profile not found" });
        }

        
        res.json({
            name: user.name,
            phone: user.phone,
            role: user.type, 
            profilePic: user.profilePic || "",
        });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

//get notification
adminRouter.get("/admin/track-tasks", adminMiddleware, async (req, res) => {
    try {
        // Find all schedules and populate both Customer and Employee details
        const tasks = await Schedule.find()
            .populate("userId", "name phone")    // Populate Customer info
            .populate("assignedTo", "name phone") // Populate Employee info
            .sort({ updatedAt: -1 });

        res.json({ success: true, tasks: tasks || [] });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});
module.exports = adminRouter;