import express from 'express';
import { forgotPassword, loginUser, logoutUser, registerUser, resetPassword } from '../controllers/authControllers.js';

const router = express.Router();

router.route("/register").post(registerUser);
router.route("/login").post(loginUser);
router.route("/logout").get(logoutUser);
router.route("/password/forgot").post(forgotPassword);
router.route("/password/reset/:token").put(resetPassword);




export default router;