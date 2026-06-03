import React, { useEffect } from "react";
import Loader from "../layout/Loader";
import { toast } from "react-hot-toast";
import { MDBDataTable } from "mdbreact";
import MetaData from "../layout/MetaData";
import AdminLayout from "../layout/AdminLayout";
import {
  useDeleteSellerMutation,
  useGetAdminSellersQuery,
  useApproveSellerMutation,
} from "../../redux/api/userApi";

const ListBecomeSeller = () => {
  const { data, isLoading, error } = useGetAdminSellersQuery();

  const [deleteSeller, { error: deleteError, isSuccess: deleteSuccess }] =
    useDeleteSellerMutation();

  const [approveSeller, { error: approveError, isSuccess: approveSuccess }] =
    useApproveSellerMutation();

  useEffect(() => {
    if (error) toast.error(error?.data?.message || "Error fetching sellers");
    if (deleteError) toast.error(deleteError?.data?.message || "Error deleting seller");
    if (approveError) toast.error(approveError?.data?.message || "Error approving seller");
    if (deleteSuccess) toast.success("Seller request deleted");
    if (approveSuccess) toast.success("Seller approved — user is now a shopkeeper");
  }, [error, deleteError, approveError, deleteSuccess, approveSuccess]);

  const setSellers = () => {
    const sellers = {
      columns: [
        { label: "Name", field: "name", sort: "asc" },
        { label: "Email", field: "email", sort: "asc" },
        { label: "Shop Name", field: "shopName", sort: "asc" },
        { label: "Shop Address", field: "shopAddress", sort: "asc" },
        { label: "PIN Code", field: "pinCode", sort: "asc" },
        { label: "Status", field: "status", sort: "asc" },
        { label: "Actions", field: "actions" },
      ],
      rows: [],
    };

    data?.sellers?.forEach((seller) => {
      const isPending = seller?.status === "pending" || !seller?.status;
      sellers.rows.push({
        name: seller?.name,
        email: seller?.email,
        shopName: seller?.shopName,
        shopAddress: seller?.shopAddress,
        pinCode: seller?.pinCode,
        status: (
          <span
            className={`badge ${isPending ? "bg-warning text-dark" : "bg-success"}`}
          >
            {seller?.status || "pending"}
          </span>
        ),
        actions: (
          <>
            {isPending && (
              <button
                className="btn btn-outline-success me-2"
                onClick={() => approveSeller(seller?._id)}
              >
                <i className="fa fa-check"></i> Approve
              </button>
            )}
            <button
              className="btn btn-outline-danger"
              onClick={() => deleteSeller(seller?._id)}
            >
              <i className="fa fa-trash"></i>
            </button>
          </>
        ),
      });
    });

    return sellers;
  };

  if (isLoading) return <Loader />;

  return (
    <AdminLayout>
      <MetaData title={"Seller Requests"} />
      <h1 className="my-5">{data?.sellers?.length} Seller Requests</h1>
      <MDBDataTable
        data={setSellers()}
        className="px-3"
        bordered
        striped
        hover
      />
    </AdminLayout>
  );
};

export default ListBecomeSeller;
