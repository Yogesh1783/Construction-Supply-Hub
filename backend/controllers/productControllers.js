import catchAsyncErrors from "../middlewares/catchAsyncErrors.js";
import Product from "../models/product.js";
import ErrorHandler from "../utils/errorHandler.js";
import APIFilters from "../utils/apiFilters.js";

//Create new product=>/api/v1/products
export const getProducts = catchAsyncErrors(async(req,res)=>{
    try {
        //search option implemented here
        const resPerPage = 4;

        const apiFilters=new APIFilters(Product,req.query).search().filters()

    let products=await apiFilters.query;
    let filterProductCount=products.length

    apiFilters.pagination(resPerPage);
    products=await apiFilters.query.clone();
        
        if (products) {
            return res.status(200).json({count : filterProductCount,products,resPerPage})
        }
        return res.status(200).json({message : "No data found"})
    } catch (error) {
        return res.status(500).json({message:error})
    }
});
// //Create new product=>/api/v1/admin/products
export const newProduct = catchAsyncErrors(async(req,res)=>{

    req.body.user=req.user._id;
    const product = await Product.create(req.body)
    res.status(200).json({
        Product,
    })
});
//Single product
export const getProductDetails = (async(req,res,next)=>{
    
        const products = await Product.findById(req?.params?.id)
        if (!products) {
            return next(new ErrorHandler('product not found',404));
            // return res.status(404).json({
            //     error : "Product not found",});
        }
        res.status(200).json({
            products,
        })
    
   
});
//update products details
export const updateProduct = catchAsyncErrors(async(req,res)=>{
    
    let products = await Product.findById(req?.params?.id)
    if (!products) {
        return res.status(404).json({
            error : "Product not found",});
    }
    products=await Product.findByIdAndUpdate(req?.params?.id,req.body,{new:true})
    res.status(200).json({
        products,
    })


});

//delete products
export const deleteProduct = catchAsyncErrors(async(req,res)=>{
    
    let products = await Product.findById(req?.params?.id)
    if (!products) {
        return res.status(404).json({
            error : "Product not found",});
    }

    await products.deleteOne()


    res.status(200).json({
        message:"Product Deleted",
    })


});