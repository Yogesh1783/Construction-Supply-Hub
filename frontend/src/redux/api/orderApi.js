import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

export const orderApi = createApi({
  reducerPath: "orderApi",
  baseQuery: fetchBaseQuery({ baseUrl: "/api/v1" }),
  endpoints: (builder) => ({
    createNewOrder: builder.mutation({
      query(body) {
        return {
          url: "/orders/new",
          method: "POST",
          body,
        };
      },
    }),
   
    myOrders: builder.query({
      query: () => `/me/orders`,
    }),
    orderDetails: builder.query({
      query: (id) => `/orders/${id}`,
    }),
    stripeCheckoutSession: builder.mutation({
      query(body) {
        return {
          url: "/payment/checkout_session",
          method: "POST",
          body,
        };
      },
    }),
    getDashboardSales: builder.query({
      query: ({ startDate, endDate }) =>
        `/admin/get_sales/?startDate=${startDate}&endDate=${endDate}`,
    }),
    getShopkeeperDashboardSales: builder.query({
      query: ({ startDate, endDate }) =>
        `/shopkeeper/get_sales/?startDate=${startDate}&endDate=${endDate}`,
    }),
    getAdminOrders: builder.query({
      query: () => `/admin/orders`,
      providesTags:["AdminOrders"],
    }),
    getShopkeeperOrders: builder.query({
      query: () => `/shopkeeper/orders/${localStorage.getItem("loggedInUserId")}`,
      providesTags:["ShopkeeperOrders"],
    }),
    updateOrder: builder.mutation({
      query({ id, body }) {
        return {
          url: `/admin/orders/${id}`,
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Order"],
    }),
    updateShopkeeperOrder: builder.mutation({
      query({ id, body }) {
        return {
          url: `/shopkeeper/orders/${id}`,
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Order"],
    }),
    updateAdminPayment: builder.mutation({
      query({ id, body }) {
        return {
          url: `admin/orders/${id}/update_payment_status`,
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Order"],
    }),
    updateShopkeeperPayment: builder.mutation({
      query({ id, body }) {
        return {
          url: `shopkeeper/orders/${id}/update_payment_status`,
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Order"],
    }),
    deleteOrder: builder.mutation({
      query(id) {
        return {
          url: `/admin/orders/${id}`,
          method: "DELETE",
        };
      },
      invalidatesTags: ["AdminOrders"],
    }),
    deleteShopkeeperOrder: builder.mutation({
      query(id) {
        return {
          url: `/shopkeeper/orders/${id}`,
          method: "DELETE",
        };
      },
      invalidatesTags: ["ShopkeeperOrders"],
    }),
  }),
});

export const {
  useCreateNewOrderMutation,
  useStripeCheckoutSessionMutation,
  useMyOrdersQuery,
  useOrderDetailsQuery,
  useLazyGetDashboardSalesQuery,
  useGetAdminOrdersQuery,
  useUpdateOrderMutation,
  useDeleteOrderMutation,
  useLazyGetShopkeeperDashboardSalesQuery,
  useGetShopkeeperOrdersQuery,
  useDeleteShopkeeperOrderMutation,
  useUpdateShopkeeperOrderMutation,
  useUpdateAdminPaymentMutation,
  useUpdateShopkeeperPaymentMutation,
  
  
} = orderApi;