const express = require("express");
const User = require("../models/user");
const bcryptjs = require('bcryptjs');
const jwt = require('jsonwebtoken');
const auth = require("../middleware/auth");

const authRouter = express.Router();

// 1. Sign up
authRouter.post('/api/signup', async (req, res) => {
    try {
        const { name, phone, password } = req.body;
        const existingUser = await User.findOne({ phone });
        if (existingUser) {
            return res.status(400).json({ msg: "User with this phone number already exists!" });
        }
        const hashedPassword = await bcryptjs.hash(password, 8);
        let user = new User({ phone, password: hashedPassword, name });
        user = await user.save();
        res.json(user);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 2. Sign In
authRouter.post('/api/signin', async (req, res) => {
    try {
        const { phone, password } = req.body;
        const user = await User.findOne({ phone });
        if (!user) return res.status(400).json({ msg: "User does not exist!" });

        const isMatch = await bcryptjs.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ msg: "Incorrect password." });

        const token = jwt.sign({ id: user._id }, "passwordKey");
        res.json({ token, ...user._doc });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 3. Forgot Password
authRouter.post('/api/forgot-password', async (req, res) => {
    try {
        const { phone } = req.body;
        const user = await User.findOne({ phone });
        if (!user) return res.status(400).json({ msg: "User not found!" });

        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        user.passwordResetOtp = otp;
        user.passwordResetExpires = Date.now() + 600000; 
        await user.save();

        console.log(`OTP for ${phone} is: ${otp}`); // testing
        res.json({ msg: "OTP sent to your phone!" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 4. Reset Password 
authRouter.post('/api/reset-password', async (req, res) => {
    try {
        const { phone, otp, newPassword } = req.body;
        const user = await User.findOne({ 
            phone, 
            passwordResetOtp: otp, 
            passwordResetExpires: { $gt: Date.now() } 
        });

        if (!user) return res.status(400).json({ msg: "Invalid or expired OTP!" });

        user.password = await bcryptjs.hash(newPassword, 8);
        user.passwordResetOtp = undefined;
        user.passwordResetExpires = undefined;
        await user.save();

        res.json({ msg: "Password updated successfully!" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = authRouter;