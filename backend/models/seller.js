import mongoose from "mongoose";

const sellerSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.ObjectId,
      ref: "User",
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
    },
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

export default mongoose.model("Seller", sellerSchema);
