import "./App.css";

import { BrowserRouter as Router, Routes } from "react-router-dom";

import Footer from "./components/layout/Footer";
import Header from "./components/layout/Header";
import { Toaster } from "react-hot-toast";

import useUserRoutes from "./components/routes/userRoutes";
import useAdminRoutes from "./components/routes/adminRoutes";
import useShopkeeperRoutes from './components/routes/shopkeeperRoutes';

function App() {
  const userRoutes = useUserRoutes();
  const adminRoutes = useAdminRoutes();
  const shopkeeperRoutes = useShopkeeperRoutes();

  

  return (
    <Router>
      <div className="App">
        <Toaster position="top-center" />
        <Header />

        <div className="container">
          <Routes>
            {userRoutes}
            {adminRoutes}
            {shopkeeperRoutes}
          </Routes>
        </div>

        <Footer />
      </div>
    </Router>
  );
}

export default App;