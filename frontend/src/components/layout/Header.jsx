import React from "react";
import Search from "./Search";
import { useGetMeQuery } from "../../redux/api/userApi";
import { useSelector } from "react-redux";
import { Link, useNavigate } from "react-router-dom";
import { useLazyLogoutQuery } from "../../redux/api/authApi";
import PinCode from "./PinCode";

const Header = ({ theme }) => {
  const navigate = useNavigate();

  const { isLoading } = useGetMeQuery();
  const [logout] = useLazyLogoutQuery();

  const { user } = useSelector((state) => state.auth);

  const isAdmin = user && user.role === "admin";
  const isShopkeeper = user && user.role === "shopkeeper";

  const { cartItems } = useSelector((state) => state.cart);

  const logoutHandler = () => {
    logout();
    localStorage.removeItem("loggedInUserId");
    navigate(0);
  };

  return (
    <>
      <style>{`
      /* Header.css */

.header-container {
  width: 100%;
  padding: 10px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

/* Default theme */
.header-container {
  background-color: #333;
  color: white;
}

/* Light theme */
.header-container.light {
  background-color: #f0f0f0;
  color: #333;
}

/* Dark theme */
.header-container.dark {
  background-color: #222;
  color: white;
}

.navbar-brand a {
  text-decoration: none;
  color: inherit;
}

.navbar-brand a:hover {
  text-decoration: none;
  color: inherit;
}

.navbar-brand p {
  margin: 0;
  font-size: 1.5rem;
}

.dropdown-toggle::after {
  display: none;
}

.avatar-nav img {
  width: 30px;
  height: 30px;
  margin-right: 5px;
}

.dropdown-menu {
  background-color: #333 !important;
}

.dropdown-item {
  color: white !important;
}

.dropdown-item:hover {
  background-color: #555 !important;
}

#cart {
  color: white;
  font-size: 1.2rem;
}

#cart_count {
  background: #fe6701;
  color: white;
  border-radius: 50%;
  padding: 0 5px;
  font-size: 0.8rem;
  position: relative;
  top: -5px;
}

      `}</style>
      <nav className={`navbar row header-container ${theme}`}>
        <div className="col-12 col-md-3 ps-5">
          <div className="navbar-brand">
            <a href="/" style={{ textDecoration: "none", color: "white" }}>
              <p>
                {" "}
                <b>Construction Supply Hub</b>{" "}
              </p>
            </a>
          </div>
        </div>
        <div className="col-6 col-md-3 mt-2 mt-md-0">
          <Search />
        </div>
        <div className="col-6 col-md-3 mt-2 mt-md-0">
          <PinCode />
        </div>
        <div className="col-12 col-md-3 mt-4 mt-md-0 text-center">
          <a href="/cart" style={{ textDecoration: "none" }}>
            <span id="cart" className="ms-3">
              {" "}
              Cart{" "}
            </span>
            <span className="ms-1" id="cart_count">
              {cartItems?.length}
            </span>
          </a>

          {user ? (
            <div className="ms-4 dropdown">
              <button
                className="btn dropdown-toggle text-white"
                type="button"
                id="dropDownMenuButton"
                data-bs-toggle="dropdown"
                aria-expanded="false"
              >
                <figure className="avatar avatar-nav">
                  <img
                    src={
                      user?.avatar
                        ? user?.avatar?.url
                        : "/images/default_avatar.jpg"
                    }
                    alt="User Avatar"
                    className="rounded-circle"
                  />
                </figure>
                <span>{user?.name}</span>
              </button>
              <div
                className="dropdown-menu w-100"
                aria-labelledby="dropDownMenuButton"
              >
                {(isAdmin || isShopkeeper) && (
                  <Link
                    className="dropdown-item"
                    to={isAdmin ? "/admin/dashboard" : "/shopkeeper/dashboard"}
                  >
                    {" "}
                    Dashboard{" "}
                  </Link>
                )}

                <Link className="dropdown-item" to="/me/orders">
                  {" "}
                  Orders{" "}
                </Link>

                <Link className="dropdown-item" to="/me/profile">
                  {" "}
                  Profile{" "}
                </Link>

                {!(isAdmin || isShopkeeper) && (
                  <Link className="dropdown-item" to="/become-seller">
                    {" "}
                    Become a Seller{" "}
                  </Link>
                )}

                <Link
                  className="dropdown-item text-danger"
                  to="/"
                  onClick={logoutHandler}
                >
                  Logout{" "}
                </Link>
              </div>
            </div>
          ) : (
            !isLoading && (
              <Link to="/login" className="btn ms-4" id="login_btn">
                {" "}
                Login{" "}
              </Link>
            )
          )}
        </div>
      </nav>
    </>
  );
};

export default Header;
