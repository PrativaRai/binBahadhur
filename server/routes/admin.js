const express = require("express");
const mongoose = require("mongoose");
const adminRouter = express.Router();

const Complain = require("../models/complain");
const User = require("../models/user");
const Schedule = require("../models/schedule");
const Report = require("../models/report");

const adminMiddleware = require("../middleware/admin");

// GET complaints
adminRouter.get("/admin/get-complain", adminMiddleware, async (req, res) => {
  try {
    const complaints = await Complain.find({}).sort({ createdAt: -1 });

    res.json({ success: true, complaints });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// DELETE complaint
adminRouter.post(
  "/admin/delete-complain",
  adminMiddleware,
  async (req, res) => {
    try {
      const { id } = req.body;

      const deleted = await Complain.findByIdAndDelete(id);

      if (!deleted) {
        return res
          .status(404)
          .json({ success: false, msg: "Complaint not found" });
      }

      res.json({ success: true, deleted });
    } catch (e) {
      res.status(500).json({ success: false, error: e.message });
    }
  },
);

// UPDATE user status
adminRouter.post(
  "/admin/update-user-status",
  adminMiddleware,
  async (req, res) => {
    try {
      const { phoneNumber, targetStatus } = req.body;

      const user = await User.findOneAndUpdate(
        { phone: phoneNumber },
        { status: targetStatus },
        { new: true },
      );

      if (!user) {
        return res.status(404).json({ success: false, msg: "User not found" });
      }

      res.json({ success: true, user });
    } catch (e) {
      res.status(500).json({ success: false, error: e.message });
    }
  },
);

// GET admin profile
adminRouter.get("/api/profile/:id", adminMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, msg: "Admin not found" });
    }

    res.json({
      success: true,
      profile: {
        name: user.name,
        phone: user.phone,
        role: user.type,
        profilePic: user.profilePic || "",
      },
    });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// GET tasks
adminRouter.get("/admin/track-tasks", adminMiddleware, async (req, res) => {
  try {
    const tasks = await Schedule.find()
      .populate("userId", "name phone")
      .populate("assignedTo", "name phone")
      .sort({ updatedAt: -1 });

    res.json({ success: true, tasks });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// GET reports
adminRouter.get("/admin/get-reports", adminMiddleware, async (req, res) => {
  try {
    const reports = await Report.find({}).sort({ createdAt: -1 });

    res.json({ success: true, reports });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// ACCEPT report + add points
adminRouter.post("/admin/accept-report", adminMiddleware, async (req, res) => {
  try {
    const { reportId } = req.body;

    const report = await Report.findById(reportId);

    if (!report) {
      return res.status(404).json({ success: false, msg: "Report not found" });
    }

    if (report.status !== "pending") {
      return res.status(400).json({ success: false, msg: "Already processed" });
    }

    report.status = "accepted";
    await report.save();

    const user = await User.findOneAndUpdate(
      { phone: report.phone },
      { $inc: { points: 1 } },
      { new: true },
    );

    if (!user) {
      return res.status(404).json({ success: false, msg: "User not found" });
    }

    res.json({ success: true, report });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// REJECT report
adminRouter.post("/admin/reject-report", adminMiddleware, async (req, res) => {
  try {
    const { reportId } = req.body;

    const report = await Report.findById(reportId);

    if (!report) {
      return res.status(404).json({ success: false, msg: "Report not found" });
    }

    report.status = "rejected";
    await report.save();

    res.json({ success: true, report });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

module.exports = adminRouter;
