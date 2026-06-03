import React from "react";
import { Route } from "react-router-dom";
import ProtectedRoute from "../auth/ProtectedRoute";
import ShopkeeperDashboard from "./../shopkeeper/ShopkeeperDashboard";
import NewProduct from "../shopkeeper/NewProductShopkeeper";
import ListOrderShopkeeper from "../shopkeeper/ListOrderShopkeeper";
import ListProductShopkeeper from "../shopkeeper/ListProductShopkeeper";
import ProcessOrderShopkeeper from "../shopkeeper/ProcessOrderShopkeeper";
import UpdateProductShopkeeper from "../shopkeeper/UpdateProductShopkeeper";
import UploadImageShopkeeper from "../shopkeeper/UploadImageShopkeeper";

const shopkeeperRoutes = () => {
  return (
    <>
      <Route
        path="/shopkeeper/dashboard"
        element={
          <ProtectedRoute shopkeeper={true}>
            <ShopkeeperDashboard />
          </ProtectedRoute>
        }
      />
      <Route
        path="/shopkeeper/orders"
        element={
          <ProtectedRoute shopkeeper={true}>
            <ListOrderShopkeeper />
          </ProtectedRoute>
        }
      />
      <Route
        path="/shopkeeper/product/new"
        element={
          <ProtectedRoute shopkeeper={true}>
            <NewProduct />
          </ProtectedRoute>
        }
      />
      <Route
        path="/shopkeeper/products"
        element={
          <ProtectedRoute shopkeeper={true}>
            <ListProductShopkeeper />
          </ProtectedRoute>
        }
      />

      <Route
        path="/shopkeeper/products/:id"
        element={
          <ProtectedRoute shopkeeper={true}>
            <UpdateProductShopkeeper />
          </ProtectedRoute>
        }
      />
      <Route
        path="/shopkeeper/products/:id/upload_images"
        element={
          <ProtectedRoute shopkeeper={true}>
            <UploadImageShopkeeper />
          </ProtectedRoute>
        }
      />

      <Route
        path="/shopkeeper/orders/:id"
        element={
          <ProtectedRoute shopkeeper={true}>
            <ProcessOrderShopkeeper />
          </ProtectedRoute>
        }
      />
    </>
  );
};

export default shopkeeperRoutes;
