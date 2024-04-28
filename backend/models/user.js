import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import crypto from "crypto";

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Please enter your name"],
      maxLength: [50, "Your name cannot exceed 50 characters"],
    },
    email: {
      type: String,
      required: [true, "Please enter your email"],
      unique: true,
    },
    password: {
      type: String,
      required: [true, "Please enter your password"],
      minLength: [6, "Your password must be longer than 6 characters"],
      select: false,
    },
    avatar: {
      public_id: String,
      url: String,
    },
    role: {
      type: String,
      enum: ["user", "shopkeeper"],
      default: "user",
    },
    resetPasswordToken: String,
    resetPasswordExpire: Date,

    shopName: {
      type: String,
      maxLength: [100, "Your shop name cannot exceed 100 characters"],
      
    },
    shopAddress: {
      type: String,
      
    },
    pinCode: {
      type: String,
    },
  },
  { timestamps: true }
);

// Middleware to restrict fields for regular users
userSchema.pre("save", function(next) {
  if (this.role !== "shopkeeper") {
    this.shopName = undefined;
    this.shopAddress = undefined;
    this.pinCode = undefined;
  }
  next();
});

// Middleware to restrict fields for regular users during update
userSchema.pre("findOneAndUpdate", function(next) {
  const update = this.getUpdate();
  if (update.role === "shopkeeper") {
    this._update.shopName = update.shopName;
    this._update.shopAddress = update.shopAddress;
    this._update.pinCode = update.pinCode;
  } else if (update.role === "user") {
    // Clear shop-related fields if role is updated to "user"
    this._update.$unset = {
      shopName: 1,
      shopAddress: 1,
      pinCode: 1
    };
  }
  next();
});


// Encrypting password before saving the user
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) {
    next();
  }

  this.password = await bcrypt.hash(this.password, 10);
});

// Return JWT Token
userSchema.methods.getJwtToken = function () {
  return jwt.sign({ id: this._id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_TIME,
  });
};

// Compare user password
userSchema.methods.comparePassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Generate password reset token
userSchema.methods.getResetPasswordToken = function () {
  // Gernerate token
  const resetToken = crypto.randomBytes(20).toString("hex");

  // Hash and set to resetPasswordToken field
  this.resetPasswordToken = crypto
    .createHash("sha256")
    .update(resetToken)
    .digest("hex");

  // Set token expire time
  this.resetPasswordExpire = Date.now() + 30 * 60 * 1000;

  return resetToken;
};

export default mongoose.model("User", userSchema);