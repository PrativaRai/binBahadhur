const express = require("express");
const User = require("../models/user");
const bcryptjs = require("bcryptjs");
const authRouter = express.Router();
const jwt = require("jsonwebtoken");
const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');

// whatsappclient setup (unchanged)
const client = new Client({
    authStrategy: new LocalAuth({
        dataPath: './.wwebjs_auth' 
    }),
    puppeteer: {
        headless: true,
        handleSIGINT: false, 
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-extensions',
        ],
    }
});

const otpStore = {}; 

client.on('qr', (qr) => {
    console.log('--- SCAN THIS QR CODE WITH WHATSAPP ---');
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('WhatsApp Client is ready!');
});

client.initialize().catch(err => console.error("WA Init Error:", err));

// --- API Routes ---

// 1. Send OTP
authRouter.post("/api/send-otp", async (req, res) => {
    try {
        const { phone } = req.body;
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        
        const formattedPhone = phone.startsWith('+') ? phone.substring(1) : `977${phone}`;
        const chatId = `${formattedPhone}@c.us`;

        otpStore[phone] = otp;

        await client.sendMessage(chatId, `Your binBahadhur verification code is: ${otp}`);
        res.json({ msg: "OTP sent successfully!" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 2. Signup User (CORRECTED)
authRouter.post("/api/signup", async (req, res) => {
    try {
        const { name, phone, password, otp } = req.body;

        // Check OTP
        if (otpStore[phone] !== otp) {
            return res.status(400).json({ msg: "Invalid or expired OTP." });
        }

        // Check if user exists
        const existingUser = await User.findOne({ phone });
        if (existingUser) {
            return res.status(400).json({ msg: "User with this phone already exists!" });
        }

        /* 
           REMOVED: The suspension check during signup. 
           You cannot find a user by "phoneNumber" before they are created. 
           Suspension logic applies to existing users during Sign-in.
        */

        const hashedPassword = await bcryptjs.hash(password, 8);

        // Use a different variable name (newUser) to avoid redeclaring 'user'
        let newUser = new User({
            name,
            phone,
            password: hashedPassword,
            status: 'active' 
        });

        newUser = await newUser.save();
        
        delete otpStore[phone]; 
        res.json(newUser);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 3. Sign In (CORRECTED)
authRouter.post("/api/signin", async (req, res) => {
    try {
        const { phone, password } = req.body;

        const user = await User.findOne({ phone });
        if (!user) {
            return res.status(400).json({ msg: "User with this phone number does not exist!" });
        }

        // Check suspension
        if (user.status === 'suspended') {
            return res.status(403).json({ msg: "Your account has been suspended. Please contact admin." });
        }

        const isMatch = await bcryptjs.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ msg: "Incorrect password." });
        }

        const token = jwt.sign({ id: user._id }, "passwordKey");
        res.json({ token, ...user._doc });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 4. Forgot Password (unchanged)
authRouter.post("/api/forgot-password", async (req, res) => {
    try {
        const { phone } = req.body;
        const user = await User.findOne({ phone });
        if (!user) return res.status(400).json({ msg: "User not found!" });

        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        otpStore[phone] = otp;

        const formattedPhone = phone.startsWith('+') ? phone.substring(1) : `977${phone}`;
        await client.sendMessage(`${formattedPhone}@c.us`, `Your binBahadhur reset code is: ${otp}`);
        
        res.json({ msg: "Reset code sent!" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 5. Reset Password (unchanged)
authRouter.post("/api/reset-password", async (req, res) => {
    try {
        const { phone, otp, newPassword } = req.body;
        if (otpStore[phone] !== otp) return res.status(400).json({ msg: "Invalid OTP" });

        const hashedPassword = await bcryptjs.hash(newPassword, 8);
        await User.findOneAndUpdate({ phone }, { password: hashedPassword });

        delete otpStore[phone];
        res.json({ msg: "Password updated successfully!" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = authRouter;