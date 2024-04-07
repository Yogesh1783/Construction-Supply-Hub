import mongoose from "mongoose";

const productSchema=new mongoose.Schema({
    name:{
        type:String,
        required:[true,'Please enter product name'],
        maxLength:[200,'Product name cannot exceed 200']
    },
    price:{
        type:Number,
        required:[true,"Please enter product price"],maxLength:[5,"Product price cannot exceed 5 digits"]
    },
    description:{
        type:String,
        required:[true,'Please enter product description'],
    },
    ratings:{
        type:Number,
        default:0
    },
    images:[
        {
        public_id: {
            type:String,
            required:true
        },
        url:{
            type:String,
            required:true,
        },
    },
    ],
    category:{
        type:String,
        required:[true,"Please enter product category"],
        enum:{
            values:['Electronics',
                    'Camera',
                    'Laptops',
                    'Accessories',
                    'Headphones',
                    'Food',
                    'Books',
                    'Sports',
                    'Outdoors',
                    'Home',
        ],
            message:'Please select correct category',
        },
    },
    seller:{
        type:String,
        required:[true,"Please enter product seller"],
    },
    stock:{
        type:Number,
        required:[true,"Please enter product sales"],
    },
    numOfReviews:{
        type:Number,
        default:0,
    },
    reviews:[
        {
        user:{
            type:mongoose.Schema.Types.ObjectId,
            ref:'User',
            required:false,
        },
        rating:{
            type:Number,
            required:true
        },
        Comment:{
            type:String,
            required:true
        },
    },
    ],
    user:{
        type:mongoose.Schema.Types.ObjectId,
        ref:'User',
        required:true,
    },
   

},{timestamps:true});

export default mongoose.model("Product", productSchema);