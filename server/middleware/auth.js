const jwt = require("jsonwebtoken");
const User = require("../models/user");

const auth = async (req, res, next) => {
  try {
    // Get token
    const token = req.header("x-auth-token");

    if (!token) {
      return res.status(401).json({
        success: false,
        msg: "No auth token, access denied",
      });
    }

    // Verify token
    const verified = jwt.verify(token, "passwordKey");

    if (!verified) {
      return res.status(401).json({
        success: false,
        msg: "Token verification failed",
      });
    }

    // Find user
    const user = await User.findById(verified.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found",
      });
    }

    // Check suspension
    if (user.status === "suspended") {
      return res.status(403).json({
        success: false,
        msg: "Account suspended",
      });
    }

    // IMPORTANT
    // req.user = phone number
    req.user = user.phone;

    // save actual mongo id separately
    req.userId = user._id;

    req.token = token;

    next();
  } catch (err) {
    console.log(err);

    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
};

module.exports = auth;