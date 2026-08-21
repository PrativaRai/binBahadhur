const jwt = require("jsonwebtoken");
const User = require('../models/user');

const employee = async (req, res, next) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) {
      return res.status(401).json({ msg: "No auth token, access denied" });
    }

    const verified = jwt.verify(token, process.env.JWT_SECRET);
    if (!verified) {
      return res.status(401).json({ msg: "Invalid token" });
    }

    const user = await User.findById(verified.id);
    if (!user) {
      return res.status(401).json({ msg: "User not found" });
    }

    // employee matrw aily ko lage employee navako ly user lekeheko 
    if (user.type !== 'employee') {
      return res.status(403).json({ msg: "Access denied. Employees only." });
    }

    req.user = verified.id;
    req.token = token;
    next();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

module.exports = employee;