const express = require('express'); //create router to handle api
const reportRouter = express.Router();
const Report = require('../models/report');
const auth = require('../middleware/auth');

// Create a new report
reportRouter.post('/api/report', auth, async (req, res) => {
    try {
        const { area, subArea } = req.body;

        const report = new Report({
            phone: req.user,
            area,
            subArea,
        });

        await report.save();

        res.json({ msg: 'Report created successfully', report });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Get all reports for a user
reportRouter.get('/api/report', auth, async (req, res) => {
    try {
        const reports = await Report.find({ phone: req.user });
        res.json(reports);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = reportRouter;