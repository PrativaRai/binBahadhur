const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    name: {
        required: true,
        type: String,
        trim: true,
    },

    phone: { 
        required: true,
        type: String,
        trim: true,
        unique: true, 
        validate: {
            validator: (value) => {
                const re = /^\d{10}$/; 
                return value.match(re);
            },
            message: "Please enter a valid 10-digit phone number",
        },
    },

    password: {
        required: true,
        type: String,
        validate: {
            validator: (value) => {
                return value.length > 6;
            },
            message: "Please enter a long password",
        },
    },

    type: {
        type: String,
        default: "user",
        enum: ["user", "admin", "employee", "user_provider"],
    },

    status: { 
        type: String, 
        default: "active" 
    },

    // OTP fields
    passwordResetOtp: {
        type: String,
    },
    passwordResetExpires: {
        type: Date,
    },
});

const User = mongoose.model("User", userSchema);
module.exports = User;