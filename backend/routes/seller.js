import express from "express";
const router = express.Router();

import { authorizeRoles, isAuthenticatedUser } from "../middlewares/auth.js";
import { allSellers, deleteSeller, getSellerDetails, registerSeller } from "../controllers/seller.js";

router.route('/registerSeller').post(isAuthenticatedUser, registerSeller);
router.route('/admin/sellers').get(isAuthenticatedUser, allSellers);
router.route('/admin/sellers/:id').get(isAuthenticatedUser, getSellerDetails);
router.route('/admin/sellers/:id').delete(isAuthenticatedUser, authorizeRoles("admin"), deleteSeller);



export default router;
