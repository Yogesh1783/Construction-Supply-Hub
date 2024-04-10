import express from "express";
const app=express();
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import productRoutes from './routes/products.js'
import errorMiddleware from "./middlewares/errors.js";
import authRoutes from './routes/auth.js'
import orderRoutes from './routes/order.js'

import { connectDatabase } from "./config/dbConnect.js";




//handle uncaught exceptions
process.on('uncaughtException',(err)=>{
    console.log(`ERROR: ${err}`);
    console.log('Shutting down due to uncaught exception')
    process.exit(1);
})
// console.log(hello);


dotenv.config({ path: "backend/config/config.env" });

app.use(express.json({ limit:"10 mb"}));
app.use(cookieParser());

//Connecting to Database
connectDatabase()


//Import all routes

app.use("/api/v1",productRoutes);
app.use("/api/v1",authRoutes);
app.use("/api/v1",orderRoutes)

app.use(errorMiddleware);

const server=app.listen(process.env.PORT, () => {
    console.log(`server started on PORT:${process.env.PORT} in ${process.env.NODE_ENV} mode.`);
});

//handle unhandler promise rejections means for developer error something releated to  syntax error
process.on('unhandledRejection',(err)=>{
    console.log(`ERROR:${err}`);
    console.log('Shutting down server due to unhandled promise rejection');
    server.close();
    process.exit(1);
})