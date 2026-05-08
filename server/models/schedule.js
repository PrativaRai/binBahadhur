const mongoose = require("mongoose");

const scheduleSchema = mongoose.Schema(
  {
    // user's phone
    phone: {
      required: true,
      type: String,
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
    // Weekly, Monthly or Custom
    scheduleType: {
      type: String,
      required: true,
      enum: ["Weekly", "Monthly", "Custom"],
    },
    // only for Custom type
    scheduledDate: {
      type: Date,
    },
    // only for Custom type
    scheduledTime: {
      type: String,
    },
    // status of the pickup
    status: {
      type: String,
      default: "pending",
      enum: ["pending", "completed", "cancelled"],
    },
    //typeofwaste e.g. plastic, paper, metal
    wasteType: {
      type: String,
    },
    // price per kg
    pricePerKg: {
      type: Number,
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

const Schedule = mongoose.model("Schedule", scheduleSchema);
module.exports = Schedule;
