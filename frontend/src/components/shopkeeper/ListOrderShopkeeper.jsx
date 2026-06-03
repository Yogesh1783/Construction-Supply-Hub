import React, { useEffect } from "react";
import Loader from "../layout/Loader";
import { toast } from "react-hot-toast";
import { MDBDataTable } from "mdbreact";
import { Link } from "react-router-dom";
import MetaData from "../layout/MetaData";

import {
  useDeleteShopkeeperOrderMutation,
  useGetShopkeeperOrdersQuery,
} from "../../redux/api/orderApi";
import ShopkeeperLayout from "../layout/ShopkeeperLayout";

const ListOrderShopkeeper = () => {
  const { data, isLoading, error } = useGetShopkeeperOrdersQuery();

  const [
    deleteOrder,
    { error: deleteError, isLoading: isDeleteLoading, isSuccess },
  ] = useDeleteShopkeeperOrderMutation();

  useEffect(() => {
    if (error) {
      toast.error(error?.data?.message);
    }

    if (deleteError) {
      toast.error(deleteError?.data?.message);
    }

    if (isSuccess) {
      toast.success("Order Deleted");
    }
  }, [error, deleteError, isSuccess]);

  const deleteOrderHandler = (id) => {
    deleteOrder(id);
  };

  const setOrders = () => {
    const orders = {
      columns: [
        {
          label: "Product Name",
          field: "productName",
          sort: "asc",
        },
        {
          label: "Payment Status",
          field: "paymentStatus",
          sort: "asc",
        },
        {
          label: "Order Status",
          field: "orderStatus",
          sort: "asc",
        },

        {
          label: "Actions",
          field: "actions",
          sort: "asc",
        },
      ],
      rows: [],
    };

    data?.orders?.forEach((order) => {
      order.orderItems.forEach((orderItem) => {
        orders.rows.push({
          productName: orderItem?.name,
          paymentStatus: order?.paymentInfo?.status?.toUpperCase(),
          orderStatus: order?.orderStatus,
          actions: (
            <>
              <Link
                to={`/shopkeeper/orders/${order?._id}`}
                className="btn btn-outline-primary"
              >
                <i className="fa fa-pencil"></i>
              </Link>

              <button
                className="btn btn-outline-danger ms-2"
                onClick={() => deleteOrderHandler(order?._id)}
                disabled={isDeleteLoading}
              >
                <i className="fa fa-trash"></i>
              </button>
            </>
          ),
        });
      });
    });

    return orders;
  };

  if (isLoading) return <Loader />;

  return (
    <ShopkeeperLayout>
      <MetaData title={"All Orders"} />

      <h1 className="my-5">{data?.orders?.length} Orders</h1>

      <MDBDataTable
        data={setOrders()}
        className="px-3"
        bordered
        striped
        hover
      />
    </ShopkeeperLayout>
  );
};

export default ListOrderShopkeeper;
