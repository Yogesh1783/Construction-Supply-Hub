import "./App.css";

import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

import Home from "./components/Home";

import Footer from "./components/layout/Footer";
import Header from "./components/layout/Header";
import { Toaster } from "react-hot-toast";
import ProductDetails from "./components/product/ProductDetails";
import Login from "./components/auth/Login";
import Register from "./components/auth/Register";
import Profile from "./components/user/Profile";
import UpdateProfile from "./components/user/UpdateProfile";
import UpdatePassword from "./components/user/UpdatePassword";
import UploadAvatar from "./components/user/UploadAvatar";

function App() {
  return (
    <Router>
      <div className="App">
        <Toaster position="top-center" />
        <Header />

        <div className="container">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/product/:id" element={<ProductDetails />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route path="/me/profile" element={<Profile />} />
            <Route path="/me/update_profile" element={<UpdateProfile />} />
            <Route path="/me/update_password" element={<UpdatePassword />} />
            <Route path="/me/upload_avatar" element={<UploadAvatar />} />



          </Routes>
        </div>

        <Footer />
      </div>
    </Router>
  );
}

export default App;