import React from "react";
import SideMenu from "./SideMenu";

const ShopkeeperLayout = ({ children }) => {
  const menuItems = [
    {
      name: "Dashboard",
      url: "/shopkeeper/dashboard",
      icon: "fas fa-tachometer-alt",
    },
    {
      name: "New Product",
      url: "/shopkeeper/product/new",
      icon: "fas fa-plus",
    },
    {
      name: "Products",
      url: "/shopkeeper/products",
      icon: "fab fa-product-hunt",
    },
    {
      name: "Orders",
      url: "/shopkeeper/orders",
      icon: "fas fa-receipt",
    },
  ];

  return (
    <div>
      <div className="mt-2 mb-4 py-4">
        <h2 className="text-center fw-bolder">Shopkeeper Dashboard</h2>
      </div>

      <div className="row justify-content-around">
        <div className="col-12 col-lg-3">
          <SideMenu menuItems={menuItems} />
        </div>
        <div className="col-12 col-lg-8 user-dashboard">{children}</div>
      </div>
    </div>
  );
};

export default ShopkeeperLayout;
