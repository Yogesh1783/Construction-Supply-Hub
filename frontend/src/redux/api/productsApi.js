import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

export const productApi = createApi({
  reducerPath: "productApi",
  baseQuery: fetchBaseQuery({ baseUrl: "/api/v1" }),
  tagTypes: ["Product", "AdminProducts", "Reviews"],
  endpoints: (builder) => ({
    getProducts: builder.query({
      query: (params) => ({
        url: "/products",
        params: {
          page: params?.page,
          keyword: params?.keyword,
          category: params?.category,
          pinCode: params?.pinCode, 
          "price[gte]": params.min,
          "price[lte]": params.max,
          "ratings[gte]": params?.ratings,
        },
      }),
    }),
    getProductDetails: builder.query({
      query: (id) => `/products/${id}`,
      providesTags: ["Product"],
    }),

    getShopkeeperProductDetails: builder.query({
      query: (id) => `/products/${id}`,
      providesTags: ["Product"],
    }),
    submitReview: builder.mutation({
      query(body) {
        return {
          url: "/reviews",
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Product"],
    }),
    canUserReview: builder.query({
      query: (productId) => `/can_review/?productId=${productId}`,
    }),
    getAdminProducts: builder.query({
      query: () => `/admin/products`,
      providesTags: ["AdminProducts"],
    }),
    getShopkeeperProducts: builder.query({
      query: () => `/shopkeeper/products`,
      providesTags: ["ShopkeeperProducts"],
    }),
    createProduct: builder.mutation({
      query(body) {
        return {
          url: "/admin/products",
          method: "POST",
          body,
        };
      },
      invalidatesTags: ["AdminProducts"],
    }),
    createShopkeeperProduct: builder.mutation({
      query(body) {
        return {
          url: "/shopkeeper/products",
          method: "POST",
          body,
        };
      },
      invalidatesTags: ["ShopkeeperProducts"],
    }),
    updateProduct: builder.mutation({
      query({ id, body }) {
        return {
          url: `/admin/products/${id}`,
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Product", "AdminProducts"],
    }),
    updateShopkeeperProduct: builder.mutation({
      query({ id, body }) {
        return {
          url: `/shopkeeper/products/${id}`,
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Product", "ShopkeeperProducts"],
    }),
    uploadProductImages: builder.mutation({
      query({ id, body }) {
        return {
          url: `/admin/products/${id}/upload_images`,
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Product"],
    }),
    uploadShopkeeperProductImages: builder.mutation({
      query({ id, body }) {
        return {
          url: `/shopkeeper/products/${id}/upload_images`,
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Product"],
    }),
    deleteShopkeeperProductImage: builder.mutation({
      query({ id, body }) {
        return {
          url: `/shopkeeper/products/${id}/delete_image`,
          method: "PUT",
          body,
        };
      },
      invalidatesTags: ["Product"],
    }),
    deleteProduct: builder.mutation({
      query(id) {
        return {
          url: `/admin/products/${id}`,
          method: "DELETE",
        };
      },
      invalidatesTags: ["AdminProducts"],
    }),
    deleteShopkeeperProduct: builder.mutation({
      query(id) {
        return {
          url: `/shopkeeper/products/${id}`,
          method: "DELETE",
        };
      },
      invalidatesTags: ["ShopkeeperProducts"],
    }),
    getProductReviews: builder.query({
      query: (productId) => `/reviews?id=${productId}`,
      providesTags: ["Reviews"],
    }),
    deleteReview: builder.mutation({
      query({ productId, id }) {
        return {
          url: `/admin/reviews?productId=${productId}&id=${id}`,
          method: "DELETE",
        };
      },
      invalidatesTags: ["Reviews"],
    }),
  }),
});

export const {
  useGetProductsQuery,
  useGetProductDetailsQuery,
  useSubmitReviewMutation,
  useCanUserReviewQuery,
  useGetAdminProductsQuery,
  useCreateProductMutation,
  useUpdateProductMutation,
  useUploadProductImagesMutation,
  useDeleteProductImageMutation,
  useDeleteProductMutation,
  useLazyGetProductReviewsQuery,
  useDeleteReviewMutation,
  useGetShopkeeperProductsQuery,
  useCreateShopkeeperProductMutation,
  useDeleteShopkeeperProductMutation,
  useUpdateShopkeeperProductMutation,
  useGetShopkeeperProductDetailsQuery,
  useUploadShopkeeperProductImagesMutation,
  useDeleteShopkeeperProductImageMutation,
} = productApi;