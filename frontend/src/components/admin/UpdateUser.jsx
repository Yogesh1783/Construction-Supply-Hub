import React, { useEffect, useState } from "react";
import Loader from "../layout/Loader";
import { toast } from "react-hot-toast";

import { useNavigate, useParams } from "react-router-dom";
import MetaData from "../layout/MetaData";

import AdminLayout from "../layout/AdminLayout";
import {
  useGetUserDetailsQuery,
  useUpdateUserMutation,
} from "../../redux/api/userApi";

const UpdateUser = () => {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("");
  const [shopName, setShopName] = useState("");
  const [shopAddress, setShopAddress] = useState("");
  const [pinCode, setPinCode] = useState("");

  const navigate = useNavigate();
  const params = useParams();

  const { data } = useGetUserDetailsQuery(params?.id);

  const [updateUser, { error, isSuccess }] = useUpdateUserMutation();

  useEffect(() => {
    if (data?.user) {
      setName(data?.user?.name);
      setEmail(data?.user?.email);
      setRole(data?.user?.role);
      // Set shop related fields if user is a shopkeeper
      if (data.user.role === "shopkeeper") {
        setShopName(data.user.shopName || "");
        setShopAddress(data.user.shopAddress || "");
        setPinCode(data.user.pinCode || "");
      }
    }
  }, [data]);

  useEffect(() => {
    if (error) {
      toast.error(error?.data?.message);
    }

    if (isSuccess) {
      toast.success("User Updated");
      navigate("/admin/users");
    }
  }, [error, isSuccess]);

  const submitHandler = (e) => {
    e.preventDefault();

    const userData = {
      name,
      email,
      role,
      // Include shop related fields if user is a shopkeeper
      ...(role === "shopkeeper" && { shopName, shopAddress, pinCode }),
    };

    updateUser({ id: params?.id, body: userData });
  };

  return (
    <AdminLayout>
      <MetaData title={"Update User"} />
      <div className="row wrapper">
        <div className="col-10 col-lg-8">
          <form className="shadow-lg" onSubmit={submitHandler}>
            <h2 className="mb-4">Update User</h2>

            <div className="mb-3">
              <label htmlFor="name_field" className="form-label">
                Name
              </label>
              <input
                type="name"
                id="name_field"
                className="form-control"
                name="name"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </div>

            <div className="mb-3">
              <label htmlFor="email_field" className="form-label">
                Email
              </label>
              <input
                type="email"
                id="email_field"
                className="form-control"
                name="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>

            <div className="mb-3">
              <label htmlFor="role_field" className="form-label">
                Role
              </label>
              <select
                id="role_field"
                className="form-select"
                name="role"
                value={role}
                onChange={(e) => setRole(e.target.value)}
              >
                <option value="user">user</option>
                <option value="admin">admin</option>
                <option value="shopkeeper">shopkeeper</option>
              </select>
            </div>

            {/* Additional fields for shopkeeper */}
            {role === "shopkeeper" && (
              <>
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
              </>
            )}

            <button type="submit" className="btn update-btn w-100 py-2">
              Update
            </button>
          </form>
        </div>
      </div>
    </AdminLayout>
  );
};

export default UpdateUser;
