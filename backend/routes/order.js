import express from "express";
const router = express.Router();

import { authorizeRoles, isAuthenticatedUser } from "../middlewares/auth.js";
import {
  allOrders,
  allOrdersByShopKeeperId,
  deleteOrder,
  getOrderDetails,
  getSales,
  myOrders,
  newOrder,
  updateOrder,
  updatePaymentStatus,
} from "../controllers/orderControllers.js";

router.route("/orders/new").post(isAuthenticatedUser, newOrder);
router.route("/orders/:id").get(isAuthenticatedUser, getOrderDetails);
router.route("/me/orders").get(isAuthenticatedUser, myOrders);

router
  .route("/admin/get_sales")
  .get(isAuthenticatedUser, authorizeRoles("admin"), getSales);

router
  .route("/shopkeeper/get_sales")
  .get(isAuthenticatedUser, authorizeRoles("shopkeeper"), getSales);


router
  .route("/admin/orders")
  .get(isAuthenticatedUser, authorizeRoles("admin"), allOrders);

router
  .route("/shopkeeper/orders")
  .get(isAuthenticatedUser, authorizeRoles("shopkeeper"), allOrders);

router
.route("/shopkeeper/orders/:shopkeeperId")
.get(isAuthenticatedUser, authorizeRoles("shopkeeper"), allOrdersByShopKeeperId);

router
  .route("/admin/orders/:id")
  .put(isAuthenticatedUser, authorizeRoles("admin"), updateOrder)
  .delete(isAuthenticatedUser, authorizeRoles("admin"), deleteOrder);

router
  .route("/shopkeeper/orders/:id")
  .put(isAuthenticatedUser, authorizeRoles("shopkeeper"), updateOrder)
  .delete(isAuthenticatedUser, authorizeRoles("shopkeeper"), deleteOrder);

  router
  .route("/shopkeeper/orders/:id/update_payment_status")
  .put(isAuthenticatedUser, authorizeRoles("shopkeeper"), updatePaymentStatus)
export default router;