import React, { useEffect, useState } from "react";
import Loader from "../layout/Loader";
import { toast } from "react-hot-toast";
import { Link, useParams } from "react-router-dom";
import MetaData from "../layout/MetaData";
import {
  // Importing necessary query and mutation hooks from the orderApi slice
  useOrderDetailsQuery,
  useUpdateShopkeeperOrderMutation,
  useUpdateShopkeeperPaymentMutation,
} from "../../redux/api/orderApi";
import ShopkeeperLayout from "../layout/ShopkeeperLayout";

const ProcessOrderShopkeeper = () => {
  // State variables to store the status and paymentStatus
  const [status, setStatus] = useState("");
  const [paymentStatus, setPaymentStatus] = useState("");

  // Getting the order ID from the URL params
  const params = useParams();

  // Fetching the order details using the order ID
  const { data, isLoading } = useOrderDetailsQuery(params?.id);

  // Extracting the order data from the fetched data
  const order = data?.order || {};

  // Mutation hook for updating the order status
  const [updateOrder, { error: orderError, isSuccess: orderSuccess }] =
    useUpdateShopkeeperOrderMutation();

  // Mutation hook for updating the payment status
  const [updatePayment, { error: paymentError, isSuccess: paymentSuccess }] =
    useUpdateShopkeeperPaymentMutation();

  // Handling errors and success messages for order update
  useEffect(() => {
    if (orderError) {
      toast.error(orderError?.data?.message);
    }
    if (orderSuccess) {
      toast.success("Order updated successfully");
    }
  }, [orderError, orderSuccess]);

  // Handling errors and success messages for payment update
  useEffect(() => {
    if (paymentError) {
      toast.error(paymentError?.data?.message);
    }
    if (paymentSuccess) {
      toast.success("Payment status updated successfully");
    }
  }, [paymentError, paymentSuccess]);

  // Function to handle updating both order and payment status
  const updateOrderHandler = (id) => {
    // Data object for updating order status
    const orderData = {
      status,
    };
    // Data object for updating payment status
    const paymentData = {
      status: paymentStatus,
    };

    // Updating order status
    updateOrder({ id, body: orderData })
      .unwrap() // Unwrapping the result
      .then(() => {
        // After updating order status, updating payment status
        updatePayment({ id, body: paymentData });
      });
  };

  // If data is loading, display loader
  if (isLoading) return <Loader />;

  // Destructuring order details
  const {
    shippingInfo,
    orderItems,
    paymentInfo,
    user,
    totalAmount,
    utr,
    orderStatus,
  } = order;

  // Checking if payment is done
  const isPaid = paymentInfo?.status === "not paid" ? true : false;

  return (
    <ShopkeeperLayout>
      <MetaData title={"Process Order"} />
      <div className="row d-flex justify-content-around">
        <div className="col-12 col-lg-8 order-details">
          <h3 className="mt-5 mb-4">Order Details</h3>

          <h5>Order ID: {order?._id}</h5>
          <h5>Order Status: {orderStatus}</h5>

          <h3 className="mt-5 mb-4">Shipping Info</h3>
          <table className="table table-striped table-bordered">
            <tbody>
              <tr>
                <th scope="row">Name</th>
                <td>{user?.name}</td>
              </tr>
              <tr>
                <th scope="row">Email</th>
                <td>{user?.email}</td>
              </tr>
              <tr>
                <th scope="row">Phone No</th>
                <td>{shippingInfo?.phoneNo}</td>
              </tr>
              <tr>
                <th scope="row">Address</th>
                <td>
                  {shippingInfo?.address}, {shippingInfo?.city},{" "}
                  {shippingInfo?.zipCode}, {shippingInfo?.country}
                </td>
              </tr>
            </tbody>
          </table>

          <h3 className="mt-5 mb-4">Payment Info</h3>
          <table className="table table-striped table-bordered">
            <tbody>
              <tr>
                <th scope="row">Status</th>
                <td className={isPaid ? "greenColor" : "redColor"}>
                  <b>{paymentInfo?.status}</b>
                </td>
              </tr>
              <tr>
                <th scope="row">Method</th>
                <td>{order?.paymentMethod}</td>
              </tr>
              <tr>
                <th scope="row">UTR ID</th>
                <td>{utr}</td>
              </tr>
              <tr>
                <th scope="row">Amount Paid</th>
                <td>${totalAmount}</td>
              </tr>
            </tbody>
          </table>

          {/* Remaining code for order items */}
        </div>

        <div className="col-12 col-lg-3 mt-5">
          <h4 className="my-4">Status</h4>
          <div className="mb-3">
            <select
              className="form-select"
              name="status"
              value={status}
              onChange={(e) => setStatus(e.target.value)}
            >
              <option value="Processing">Processing</option>
              <option value="Shipped">Shipped</option>
              <option value="Delivered">Delivered</option>
            </select>
          </div>

          <h4 className="my-4">Payment Status</h4>
          <div className="mb-3">
            <select
              className="form-select"
              name="paymentStatus"
              value={paymentStatus}
              onChange={(e) => setPaymentStatus(e.target.value)}
            >
              <option value="Not Paid">Not Paid</option>
              <option value="Paid">Paid</option>
            </select>
          </div>

          {/* Button to update both order and payment status */}
          <button
            className="btn btn-primary w-100"
            onClick={() => updateOrderHandler(order?._id)}
          >
            Update Order
          </button>

          <h4 className="mt-5 mb-3">Order Invoice</h4>
          <Link
            to={`/invoice/orders/${order?._id}`}
            className="btn btn-success w-100"
          >
            <i className="fa fa-print"></i> Generate Invoice
          </Link>
        </div>
      </div>
    </ShopkeeperLayout>
  );
};

export default ProcessOrderShopkeeper;
