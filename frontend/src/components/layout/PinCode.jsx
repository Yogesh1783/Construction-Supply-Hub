import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
const PinCode = () => {
  const [pinCode, setPinCode] = useState("");
  const navigate = useNavigate();

  const submitHandler = (e) => {
    e.preventDefault();

    if (pinCode?.trim()) {
      navigate(`/?pinCode=${pinCode}`);
    } else {
      navigate(`/`);
    }
  };

  return (
    <form onSubmit={submitHandler}>
      <div className="input-group">
        <input
          type="text"
          id="search_field"
          aria-describedby="search_btn"
          className="form-control"
          placeholder="Enter Pin Code ..."
          name="pinCode"
          value={pinCode}
          onChange={(e) => setPinCode(e.target.value)}
        />
        <button id="search_btn" className="btn" type="submit">
          <i className="fa fa-search" aria-hidden="true"></i>
        </button>
      </div>
    </form>
  );
};

export default PinCode;
