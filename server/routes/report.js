const express = require("express");
const reportRouter = express.Router();
const Report = require("../models/report");
const auth = require("../middleware/auth");
const { upload, uploadToCloudinary } = require("../middleware/upload"); //new way to import the upload tools

// CREATE REPORT

reportRouter.post("/api/report", auth, async (req, res) => {
  try {
    const { area, subArea } = req.body;

    const report = new Report({
      phone: req.user,
      area,
      subArea,
    });

    await report.save();

    res.status(201).json({
      success: true,
      report,
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      error: e.message,
    });
  }
});

// UPDATE REPORT (IMAGE + DESCRIPTION) yo chahi paila area subarea halera report generate vaisakchha ani tesma image ra description add garne

reportRouter.put(
  "/api/report/:id",
  auth,
  upload.single("image"),
  async (req, res) => {
    try {
      const { description } = req.body;

      let imageUrl = undefined;

      if (req.file) {
        const cloudResult = await uploadToCloudinary(req.file.buffer);
        imageUrl = cloudResult.secure_url;
      }

      const updatedReport = await Report.findByIdAndUpdate(
        req.params.id,
        {
          ...(description && { description }),
          ...(imageUrl && { imageUrl }),
        },
        { new: true },
      );

      if (!updatedReport) {
        return res.status(404).json({
          success: false,
          msg: "Report not found",
        });
      }

      res.json({
        success: true,
        report: updatedReport,
      });
    } catch (e) {
      console.error("REPORT UPDATE CRASHED:", e);
      res.status(500).json({
        success: false,
        error: e.message,
      });
    }
  },
);

// GET ALL REPORTS (USER)

reportRouter.get("/api/report", auth, async (req, res) => {
  try {
    const reports = await Report.find({ phone: req.user });

    res.json({
      success: true,
      reports,
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      error: e.message,
    });
  }
});

// GET REPORT BY ID (confirmation page ko lagi)

reportRouter.get("/api/report/:id", auth, async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return res.status(404).json({
        success: false,
        msg: "Report not found",
      });
    }

    res.json({
      success: true,
      report,
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      error: e.message,
    });
  }
});

module.exports = reportRouter;
