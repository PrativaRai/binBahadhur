const mongoose = require("mongoose");

const scheduleSchema = mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId, // Keep this as ObjectId for .populate()
     ref: "User",    
                          
      required: true,
    },
  
    phone: {
      type: String,
      required: [true, "Phone number is required"],
      trim: true,
 
    },

    assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User", 
    default: null,
  },
    area: {
      type: String,
      required: true,
      trim: true,
    },
    subArea: {
      type: String,
      required: true,
      trim: true,
    },
    scheduleType: {
      type: String,
      required: true,
      enum: ["Weekly", "Monthly", "Custom"],
    },
    scheduledDate: {
      type: Date,
    },
    scheduledTime: {
      type: String,
    },
    status: {
      type: String,
      default: "pending", 
      enum: ['pending', 'accepted', 'assigned', 'completed', 'rejected'],
    },
    wasteType: {
      type: String,
    },
    pricePerKg: {
      type: Number,
    },
    description: {
      type: String,
    },
    imageUrl: {
      type: String,
    },
  },
  { timestamps: true },
);

const Schedule = mongoose.model("Schedule", scheduleSchema);
module.exports = Schedule;