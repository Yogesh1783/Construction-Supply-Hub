import React, { useEffect, useState } from "react";
import { toast } from "react-hot-toast";
import { useNavigate } from "react-router-dom";
import MetaData from "../layout/MetaData";
import UserLayout from "../layout/UserLayout";
import { useRegisterSellerMutation } from "../../redux/api/sellerApi";
import { useSelector } from "react-redux";

const BecomeSeller = () => {
  const [shopName, setShopName] = useState("");
  const [shopAddress, setShopAddress] = useState("");
  const [pinCode, setPinCode] = useState("");

  const navigate = useNavigate();
  const { user } = useSelector((state) => state.auth); // Assuming auth state contains user info

  const [registerSeller, { error, isSuccess }] = useRegisterSellerMutation();

  useEffect(() => {
    if (error) {
      toast.error(error?.data?.message);
    }

    if (isSuccess) {
      toast.success("Seller Registered Successfully");
      navigate("/");
    }
  }, [error, isSuccess, navigate]);

  const submitHandler = (e) => {
    e.preventDefault();

    const sellerData = {
      userId: user._id, // Pass the user ID
      shopName,
      shopAddress,
      pinCode,
    };

    registerSeller(sellerData);
  };

  return (
    <UserLayout>
      <MetaData title={"Become a Seller"} />
      <div className="row wrapper">
        <div className="col-10 col-lg-8">
          <form className="shadow-lg" onSubmit={submitHandler}>
            <h2 className="mb-4">Become a Seller</h2>

            <div className="mb-3">
              <label htmlFor="shopName_field" className="form-label">
                Shop Name
              </label>
              <input
                type="text"
                id="shopName_field"
                className="form-control"
                name="shopName"
                value={shopName}
                onChange={(e) => setShopName(e.target.value)}
              />
            </div>

            <div className="mb-3">
              <label htmlFor="shopAddress_field" className="form-label">
                Shop Address
              </label>
              <input
                type="text"
                id="shopAddress_field"
                className="form-control"
                name="shopAddress"
                value={shopAddress}
                onChange={(e) => setShopAddress(e.target.value)}
              />
            </div>

            <div className="mb-3">
              <label htmlFor="pincode_field" className="form-label">
                PinCode
              </label>
              <input
                type="text"
                id="pincode_field"
                className="form-control"
                name="pincode"
                value={pinCode}
                onChange={(e) => setPinCode(e.target.value)}
              />
            </div>

            <button type="submit" className="btn update-btn w-100 py-2">
              Become a Seller
            </button>
          </form>
        </div>
      </div>
    </UserLayout>
  );
};

export default BecomeSeller;
