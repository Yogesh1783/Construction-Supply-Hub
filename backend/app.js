import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import { connectDatabase } from "./config/dbConnect.js";
import errorMiddleware from "./middlewares/errors.js";

const app = express();

// Handle Uncaught exceptions
process.on("uncaughtException", (err) => {
  console.error(`Uncaught Exception: ${err}`);
  console.log("Shutting down due to uncaught exception");
  process.exit(1);
});

dotenv.config({ path: "backend/config/config.env" });

// Connecting to database
connectDatabase();

app.use(
  express.json({
    limit: "10mb",
    verify: (req, res, buf) => {
      req.rawBody = buf.toString();
    },
  })
);
app.use(cookieParser());

app.use((req, res, next) => {
  // Check if the cookie has expired
  if (req.cookies && req.cookies.myCookie && isExpired(req.cookies.myCookie)) {
    // Clear the cookie
    res.clearCookie("myCookie");
  }
  next();
});

// Import all routes
import productRoutes from "./routes/products.js";
import authRoutes from "./routes/auth.js";
import orderRoutes from "./routes/order.js";
import paymentRoutes from "./routes/payment.js";
import sellerRoutes from "./routes/seller.js";

app.use("/api/v1", productRoutes);
app.use("/api/v1", authRoutes);
app.use("/api/v1", orderRoutes);
app.use("/api/v1", paymentRoutes);
app.use("/api/v1", sellerRoutes);




// Using error middleware
app.use(errorMiddleware);

const server = app.listen(process.env.PORT, () => {
  console.log(
    `Server started on PORT: ${process.env.PORT} in ${process.env.NODE_ENV} mode.`
  );
});

// Handle Unhandled Promise rejections
process.on("unhandledRejection", (err) => {
  console.error("Unhandled Promise Rejection:", err.stack || err.message);
  console.log("Shutting down server due to Unhandled Promise Rejection");
  server.close(() => {
    process.exit(1);
  });
});
