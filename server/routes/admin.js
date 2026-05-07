const express = require('express');
const adminRouter = express.Router();
const Complain = require("../models/complain");
const User = require("../models/user"); 
const adminMiddleware = require("../middleware/admin");

// 1. GET ALL COMPLAINTS
adminRouter.get('/admin/get-complain', adminMiddleware, async (req, res) => {
    try {
        const complain = await Complain.find({});
        res.json(complain);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 2. RESOLVE / DELETE COMPLAINT
adminRouter.post('/admin/delete-complain', adminMiddleware, async (req, res) => {
    try {
        const { id } = req.body;
        let complain = await Complain.findByIdAndDelete(id);
        res.json(complain);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 3. UPDATE USER STATUS (SUSPEND/ACTIVATE)
adminRouter.post("/admin/update-user-status", adminMiddleware, async (req, res) => {
    try {
        // CHANGED: Receiving phoneNumber instead of email from the request body
        const { phoneNumber, targetStatus } = req.body;

        // CHANGED: Finding user by phoneNumber
        const user = await User.findOneAndUpdate(
            { phoneNumber: phoneNumber }, 
            { status: targetStatus },
            { new: true } 
        );

        if (!user) {
            // CHANGED: Updated error message for clarity
            return res.status(400).json({ msg: "User with this phone number not found!" });
        }

        res.json(user);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = adminRouter;