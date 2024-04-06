import express from 'express';
import { getProducts,newProduct , getProductDetails, updateProduct,deleteProduct, createProductReview, getProductReviews, deleteReview } from './../controllers/productControllers.js';
import { authorizeRoles, isAuthenticatedUser } from '../middlewares/auth.js';
const router = express.Router();

router.route("/products")
.get( getProducts);
router.route("/admin/products").post(isAuthenticatedUser,authorizeRoles("admin"),newProduct);

router.route("/products/:id").get(getProductDetails);

router.route("/admin/products/:id").put(isAuthenticatedUser,authorizeRoles("admin"),updateProduct); //put is used to update the product
router.route("/admin/products/:id").delete(isAuthenticatedUser,authorizeRoles("admin"),deleteProduct);

router.route("/reviews")
.put(isAuthenticatedUser,createProductReview)
.get(isAuthenticatedUser,getProductReviews)

router.route("/admin/reviews")
.delete(isAuthenticatedUser,deleteReview)

export default router;