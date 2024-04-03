import mongoose from 'mongoose';
import ProductModel from './../models/product.js';
import products from "./data.js"
const seedProduct=async()=>{
    try {
        await mongoose.connect("mongodb://localhost:27017/CSH");

        await ProductModel.deleteMany();
        console.log("Products are deleted");

        await ProductModel.insertMany(products);
        console.log("Products are added");

        process.exit();

    } catch (error) {
        console.log(error.message);
        process.exit();
        
    }
};

seedProduct()