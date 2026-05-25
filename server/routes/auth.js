const express = require("express");
const User = require("../models/user");
const bcryptjs = require("bcryptjs");
const authRouter = express.Router();
const jwt = require("jsonwebtoken");
const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const auth = require("../middleware/auth"); 
const Complain = require("../models/complain");

// client ly naya whatsapp session create garxa 
const client = new Client({
    authStrategy: new LocalAuth({
        dataPath: './.wwebjs_auth' //login session store garxa jaily delete garnu push garnu vanda agade
    }),
    puppeteer: {
        headless: true, //browser user laii na tha vae background ma run gare raakhxa
        handleSIGINT: true, 
        timeout: 60000,
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
    console.log('SCAN THIS QR CODE To Get OTP IN Whatsapp');
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('WhatsApp Client is ready!');
});

client.initialize().catch(err => console.error("WA Init Error:", err));


// Send OTP
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

// Signup User
authRouter.post("/api/signup", async (req, res) => {
    try {
        const { name, phone, password, otp,} = req.body;

        
        if (otpStore[phone] !== otp) {
            return res.status(400).json({ msg: "Invalid or expired OTP." });
        }

        // Check if user exists
        const existingUser = await User.findOne({ phone });
        if (existingUser) {
            return res.status(400).json({ msg: "User with this phone already exists!" });
        }
        const hashedPassword = await bcryptjs.hash(password, 8);
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

// 3. Sign In
authRouter.post("/api/signin", async (req, res) => {
    try {
        const { phone, password } = req.body;

        const user = await User.findOne({ phone });
        if (!user) {
            return res.status(400).json({ msg: "User with this phone number does not exist!" });
        }

        
        if (user.status === 'suspended') {
            return res.status(403).json({ msg: "Your account has been suspended. Please contact admin." });
        }

        const isMatch = await bcryptjs.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ msg: "Incorrect password." });
        }

        const token = jwt.sign({ id: user._id, type: user.type}, "passwordKey");
        res.json({ token, ...user._doc });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// 4. Forgot Password
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

// 5. Reset Password
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
//complain
// // === INLINE AUTH MIDDLEWARE ===
// const customAuth = (req, res, next) => {
//     try {
//         const token = req.header("x-auth-token");
//         if (!token) {
//             return res.status(401).json({ msg: "No auth token, access denied." });
//         }

//         // Verifies using the exact key your signin route uses
//         const verified = jwt.verify(token, "passwordKey");
//         if (!verified) {
//             return res.status(401).json({ msg: "Token verification failed, authorization denied." });
//         }

//         req.userId = verified.id; // Sets the user ID for Mongoose
//         next();
//     } catch (err) {
//         res.status(500).json({ error: err.message });
//     }
// };

// // === SUBMIT EMPLOYEE COMPLAINT ROUTE ===
// // We use customAuth here so it doesn't look for an external file!
// authRouter.post("/api/user/report-employee", customAuth, async (req, res) => {
//     try {
//         const { employeePhone, description, employeeName } = req.body;

//         if (!description || !employeePhone || !employeeName) {
//             return res.status(400).json({ 
//                 msg: "Please provide employee name, phone number, and a description." 
//             });
//         }

//         // To make sure Complain model is defined, let's pull it directly if needed
//         const Complain = require("../models/complain"); 

//         let complain = new Complain({
//             phoneNumber: employeePhone,
//             description: description,
//             employee: employeeName,
//             userId: req.userId, 
//         });

//         await complain.save();

//         res.json({
//             success: true,
//             msg: "Complaint registered and forwarded to Admin successfully",
//             complain,
//         });
//     } catch (e) {
//         res.status(500).json({ error: e.message });
//     }
// });


authRouter.post("/api/user/report-employee", auth, async (req, res) => {
  try {
    const { employeePhone, description, employeeName } = req.body;

    // Search for the target employee and make sure they are actually an employee profile
    const targetEmployee = await User.findOne({ 
      phone: employeePhone, 
      type: "employee" 
    });

    if (!targetEmployee) {
      return res.status(404).json({ 
        success: false, 
        msg: "No employee account found with this phone number." 
      });
    }

    let complain = new Complain({
      phoneNumber: employeePhone,  
      description: description,    
      employee: employeeName,      
      // Safety Fallback: Checks both variations of token assignment depending on your middleware config
      userId: req.userId || req.user, 
    });

    await complain.save();

    res.json({
      success: true,
      msg: "Complaint registered successfully",
      complain,
    });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});
module.exports = authRouter;