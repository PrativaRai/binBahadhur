const mongoose = require("mongoose");

const reportSchema = mongoose.Schema(
  {
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

    // additional details about the pickup
    description: {
      type: String,
    }, // image of the waste to be picked up
    imageUrl: {
      type: String,
    },
  },
  { timestamps: true },
);

const Report = mongoose.model("Report", reportSchema);
module.exports = Report;
