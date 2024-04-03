import ErrorHandler from "../utils/errorHandler.js";

export default (err,req,res,next)=>{
    let error ={
        statusCode:err?.statusCode||500,
        message :err?.message|| 'Internal Server Error'
    };

    //Handle Invalid Mongoose ID Error
    if(err.name==='CastError'){
        const message=`Resource not found. Invalid:${err?.path}`
        error=new ErrorHandler(message,404)
    }

    //handle validation error
    if(err.name==="ValidatorError"){
        const message=Object.values(err.errors).map((value)=>value.message);
        error=new ErrorHandler(message,400)
    }




        //error for Development means for developer
    if(process.env.NODE_ENV==='DEVELOPMENT'){
        res.status(error.statusCode).json({
            message:error.message,
            error:err,
            stack:err?.stack,
        });
    }
        //error for Production means for user
    if(process.env.NODE_ENV==='PRODUCTION'){
        res.status(error.statusCode).json({
            message:error.message,
        });
    }

    
};