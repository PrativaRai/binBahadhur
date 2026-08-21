const mongoose = require('mongoose');

const complainSchema = mongoose.Schema({
    phoneNumber: {
        required: true,
        type: String,
        trim: true,
    },
    description: {
        type: String,
        required: true,
        trim: true,
    },
    employee: {
        type: String,
        required: true,
    },
    userId: {
        type: String,
        required: true,
    }
});

const Complain = mongoose.model("Complain", complainSchema);
module.exports = Complain;