const express = require('express');
const employeeRouter = express.Router();
const employeeMiddleware = require('../middleware/employee');
const Complain = require('../models/complain'); 

// Adding complain
employeeRouter.post('/employee/add-complain', employeeMiddleware, async (req, res) => {
    try {
        const { phoneNumber, description, employee } = req.body;
        let complain = new Complain({
            phoneNumber, 
            description,
            employee,
            userId: req.user
        });
        complain = await complain.save();
        res.json(complain);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = employeeRouter;