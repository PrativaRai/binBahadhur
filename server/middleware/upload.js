const multer = require("multer");
const cloudinary = require("cloudinary").v2;
require("dotenv").config();

// 1. Initialize Cloudinary directly
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// 2. Configure Multer to use temporary memory storage instead of your hard drive
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// 3. Create a clean utility helper to upload the file buffer to Cloudinary
const uploadToCloudinary = (fileBuffer) => {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      {
        folder: "binbahadhur",
        allowed_formats: ["jpg", "jpeg", "png"],
      },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      },
    );
    uploadStream.end(fileBuffer);
  });
};

// Export both the multer parser and our cloud helper function
module.exports = { upload, uploadToCloudinary };
