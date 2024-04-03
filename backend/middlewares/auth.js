import jwt from "jsonwebtoken";
import ErrorHandler from "../utils/errorHandler.js";
import catchAsyncErrors from "./catchAsyncErrors.js";
import userModel from "../models/user.js";

//check if a user is authenticate or not
export const isAuthenticatedUser=catchAsyncErrors(async(req,res,next)=>{
    const { token }=req.cookies;

    if(!token){
        return next(new ErrorHandler("Login first to access this resource",401))
    }

   const decode=jwt.verify(token,process.env.JWT_SECRET);
   req.user=await userModel.findById(decode.id);

    next();

})

//Authorize user roles
export const authorizeRoles=(...roles)=>{
    return (req,res,next)=>{
        if(!roles.includes(req.user.role)){
            return next(new ErrorHandler(`Role (${req.user.role}) is not to access this resource`,403))
        }
        next();
    }
}