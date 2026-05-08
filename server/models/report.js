const mongoose = require('mongoose');

const reportSchema = mongoose.Schema({
    // user's phone number
    phone: {
        type: String,
        required: true,
        trim: true,
    },
    // selected area e.g. Dharan
    area: {
        type: String,
        required: true,
        trim: true,
    },
    // selected sub-area e.g. Bhanu Chowk
    subArea: {
        type: String,
        required: true,
        trim: true,
    },
    // status of the report
    status: {
        type: String,
        default: 'pending',
        enum: ['pending', 'completed', 'cancelled'],
    },
}, { timestamps: true });

const Report = mongoose.model("Report", reportSchema);
module.exports = Report;