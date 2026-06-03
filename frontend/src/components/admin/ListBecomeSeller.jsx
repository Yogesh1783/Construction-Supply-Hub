import React, { useEffect } from "react";
import Loader from "../layout/Loader";
import { toast } from "react-hot-toast";
import { MDBDataTable } from "mdbreact";
import { Link } from "react-router-dom";
import MetaData from "../layout/MetaData";
import AdminLayout from "../layout/AdminLayout";
import {
  useDeleteSellerMutation,
  useGetAdminSellersQuery,
} from "../../redux/api/userApi";

const ListBecomeSeller = () => {
  const { data, isLoading, error } = useGetAdminSellersQuery();

  const [
    deleteUser,
    { error: deleteError, isLoading: isDeleteLoading, isSuccess },
  ] = useDeleteSellerMutation();

  useEffect(() => {
    if (error) {
      toast.error(error?.data?.message || "Error fetching sellers");
    }

    if (deleteError) {
      toast.error(deleteError?.data?.message || "Error deleting seller");
    }

    if (isSuccess) {
      toast.success("Seller request Deleted");
    }
  }, [error, deleteError, isSuccess]);

  const deleteUserHandler = (id) => {
    deleteUser(id);
  };

  const setSellers = () => {
    const sellers = {
      columns: [
        {
          label: "ID",
          field: "id",
          sort: "asc",
        },
        {
          label: "Name",
          field: "name",
          sort: "asc",
        },
        {
          label: "Email",
          field: "email",
          sort: "asc",
        },
        {
          label: "Shop Name",
          field: "shopName",
          sort: "asc",
        },
        {
          label: "Shop Address",
          field: "shopAddress",
          sort: "asc",
        },
        {
          label: "Pin Code",
          field: "pinCode",
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

    data?.sellers?.forEach((seller) => {
      sellers.rows.push({
        id: seller?._id,
        name: seller?.name,
        email: seller?.email,
        shopName: seller?.shopName,
        shopAddress: seller?.shopAddress,
        pinCode: seller?.pinCode,
        actions: (
          <>
            <Link
              to={`/admin/sellers/${seller?._id}`}
              className="btn btn-outline-primary"
            >
              <i className="fa fa-pencil"></i>
            </Link>
            <button
              className="btn btn-outline-danger ms-2"
              onClick={() => deleteUserHandler(seller?._id)}
              disabled={isDeleteLoading}
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
      <MetaData title={"All Sellers"} />
      <h1 className="my-5">{data?.sellers?.length} Sellers</h1>
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
