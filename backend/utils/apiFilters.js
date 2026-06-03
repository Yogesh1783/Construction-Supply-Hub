class APIFilters {
  constructor(query, queryStr) {
    this.query = query;
    this.queryStr = queryStr;
  }

  search() {
    const keyword = this.queryStr.keyword
      ? {
          name: {
            $regex: this.queryStr.keyword,
            $options: "i",
          },
        }
      : {};

      if (this.queryStr.pinCode) {
        keyword.pinCode = this.queryStr.pinCode;
      }
  

    this.query = this.query.find({ ...keyword });
    return this;
  }

 

  filters() {
    const queryCopy = { ...this.queryStr };

    // Fields to remove
    const fieldsToRemove = ["keyword", "page", "sort", "pinCode"];
    fieldsToRemove.forEach((el) => delete queryCopy[el]);

    // Advance filter for price, ratings etc
    let queryStr = JSON.stringify(queryCopy);
    queryStr = queryStr.replace(/\b(gt|gte|lt|lte)\b/g, (match) => `$${match}`);

    this.query = this.query.find(JSON.parse(queryStr));

    // Add sorting by pinCode
    if (this.queryStr.sort === 'pinCode') {
      this.query = this.query.sort({ pinCode: 1 }); // Sort in ascending order of pinCode
    }

    return this;
  }

  pagination(resPerPage) {
    const currentPage = Number(this.queryStr.page) || 1;
    const skip = resPerPage * (currentPage - 1);

    this.query = this.query.limit(resPerPage).skip(skip);
    return this;
  }
}

export default APIFilters;
