const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
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
          // This now only allows 10-digit numbers starting with 9
          const re = /^9\d{9}$/;
          return re.test(value);
        },
        message: "Please enter a valid 10-digit phone number.",
      },
    },
    password: {
      required: true,
      type: String,
      validate: {
        validator: (value) => {
          return value.length > 6;
        },
        message: "Password must be at least 7 characters long",
      },
    },
    type: {
      type: String,
      default: "user",
      enum: ["user", "admin", "employee", "user_provider"],
    },
    status: {
      type: String,
      default: "active",
    },
    profilePic: { type: String, default: "" },
    points: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true },
);

const User = mongoose.model("User", userSchema);
module.exports = User;
