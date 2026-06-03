import catchAsyncErrors from "../middlewares/catchAsyncErrors.js";
import ErrorHandler from "../utils/errorHandler.js";
import Seller from "../models/seller.js";
import User from "../models/user.js";

// Register Seller
export const registerSeller = catchAsyncErrors(async (req, res, next) => {
  // Assuming the user is authenticated and the user ID is available in req.user
  const userId = req.user._id; // Ensure req.user is populated with authenticated user details

  // Fetch user details from the User model
  const fetchedUser = await User.findById(userId);
  if (!fetchedUser) {
    return next(new ErrorHandler('User not found', 404));
  }

  const { shopName, shopAddress, pinCode } = req.body;

  const newSeller = await Seller.create({
    user: userId,
    name: fetchedUser.name, // Use name from User model
    email: fetchedUser.email, // Use email from User model
    shopName,
    shopAddress,
    pinCode,
  });

  res.status(200).json({
    success: true,
    seller: newSeller,
  });
});

// Get all Sellers - ADMIN  =>  /api/v1/admin/sellers
export const allSellers = catchAsyncErrors(async (req, res, next) => {
  const sellers = await Seller.find().select('name email shopName shopAddress pinCode');

  res.status(200).json({
    sellers,
  });
});

// Get Seller Details - ADMIN  =>  /api/v1/admin/sellers/:id
export const getSellerDetails = catchAsyncErrors(async (req, res, next) => {
  const seller = await Seller.findById(req.params.id).select('name email');

  if (!seller) {
    return next(
      new ErrorHandler(`Seller not found with id: ${req.params.id}`, 404)
    );
  }

  res.status(200).json({
    seller,
  });
});
export const deleteSeller = catchAsyncErrors(async (req, res, next) => {
  const seller = await Seller.findById(req.params.id);

  if (!seller) {
    return next(
      new ErrorHandler(`User not found with id: ${req.params.id}`, 404)
    );
  }

  // TODO - Remove user avatar from cloudinary

  await seller.deleteOne();

  res.status(200).json({
    success: true,
  });
});
