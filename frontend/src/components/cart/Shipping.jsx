import React, { useEffect, useState } from "react";
import { countries } from "countries-list";
import { useDispatch, useSelector } from "react-redux";
import { saveShippingInfo } from "../../redux/features/cartSlice";
import { useNavigate } from "react-router-dom";
import MetaData from "../layout/MetaData";
import CheckoutSteps from "./CheckoutSteps";
import MapPicker from "../layout/MapPicker";

const Shipping = () => {
  const countriesList = Object.values(countries);

  const dispatch = useDispatch();
  const navigate = useNavigate();

  const [address, setAddress] = useState("");
  const [city, setCity] = useState("");
  const [zipCode, setZipCode] = useState("");
  const [phoneNo, setPhoneNo] = useState("");
  const [country, setCountry] = useState("");
  const [lat, setLat] = useState(null);
  const [lng, setLng] = useState(null);
  const [geocoding, setGeocoding] = useState(false);

  const { shippingInfo } = useSelector((state) => state.cart);

  useEffect(() => {
    if (shippingInfo) {
      setAddress(shippingInfo?.address);
      setCity(shippingInfo?.city);
      setZipCode(shippingInfo?.zipCode);
      setPhoneNo(shippingInfo?.phoneNo);
      setCountry(shippingInfo?.country);
      setLat(shippingInfo?.lat || null);
      setLng(shippingInfo?.lng || null);
    }
  }, [shippingInfo]);

  const handleLocationSelect = async (newLat, newLng) => {
    setLat(newLat);
    setLng(newLng);
    setGeocoding(true);

    try {
      const res = await fetch(
        `https://nominatim.openstreetmap.org/reverse?format=json&lat=${newLat}&lon=${newLng}`,
        { headers: { "Accept-Language": "en" } }
      );
      const data = await res.json();
      const a = data.address;

      const street = [a.house_number, a.road || a.pedestrian || a.footway]
        .filter(Boolean)
        .join(" ");
      setAddress(street || a.suburb || a.neighbourhood || "");
      setCity(a.city || a.town || a.village || a.county || "");
      setZipCode(a.postcode || "");

      const matchedCountry = countriesList.find(
        (c) => c.name.toLowerCase() === (a.country || "").toLowerCase()
      );
      if (matchedCountry) setCountry(matchedCountry.name);
    } catch {
      // reverse geocode failed silently — user can still type manually
    } finally {
      setGeocoding(false);
    }
  };

  const submiHandler = (e) => {
    e.preventDefault();
    dispatch(saveShippingInfo({ address, city, phoneNo, zipCode, country, lat, lng }));
    navigate("/confirm_order");
  };

  return (
    <>
      <MetaData title={"Shipping Info"} />
      <CheckoutSteps shipping />

      <div className="row wrapper mb-5">
        <div className="col-10 col-lg-5">
          <form className="shadow rounded bg-body" onSubmit={submiHandler}>
            <h2 className="mb-4">Shipping Info</h2>

            <div className="mb-3">
              <label className="form-label fw-semibold">
                Pin Your Location on Map
              </label>
              <p className="text-muted small mb-2">
                Click anywhere on the map to auto-fill your address below.
              </p>
              <MapPicker
                lat={lat}
                lng={lng}
                onLocationSelect={handleLocationSelect}
              />
              {geocoding && (
                <small className="text-primary mt-1 d-block">
                  Fetching address...
                </small>
              )}
              {lat && lng && !geocoding && (
                <small className="text-success mt-1 d-block">
                  Location pinned: {lat.toFixed(5)}, {lng.toFixed(5)}
                </small>
              )}
            </div>

            <hr />

            <div className="mb-3">
              <label htmlFor="address_field" className="form-label">
                Address
              </label>
              <input
                type="text"
                id="address_field"
                className="form-control"
                name="address"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                required
              />
            </div>

            <div className="mb-3">
              <label htmlFor="city_field" className="form-label">
                City
              </label>
              <input
                type="text"
                id="city_field"
                className="form-control"
                name="city"
                value={city}
                onChange={(e) => setCity(e.target.value)}
                required
              />
            </div>

            <div className="mb-3">
              <label htmlFor="phone_field" className="form-label">
                Phone No
              </label>
              <input
                type="tel"
                id="phone_field"
                className="form-control"
                name="phoneNo"
                value={phoneNo}
                onChange={(e) => setPhoneNo(e.target.value)}
                required
              />
            </div>

            <div className="mb-3">
              <label htmlFor="zip_code_field" className="form-label">
                Zip Code
              </label>
              <input
                type="number"
                id="zip_code_field"
                className="form-control"
                name="zipCode"
                value={zipCode}
                onChange={(e) => setZipCode(e.target.value)}
                required
              />
            </div>

            <div className="mb-3">
              <label htmlFor="country_field" className="form-label">
                Country
              </label>
              <select
                id="country_field"
                className="form-select"
                name="country"
                value={country}
                onChange={(e) => setCountry(e.target.value)}
                required
              >
                <option value="">Select Country</option>
                {countriesList?.map((c) => (
                  <option key={c?.name} value={c?.name}>
                    {c?.name}
                  </option>
                ))}
              </select>
            </div>

            <button id="shipping_btn" type="submit" className="btn w-100 py-2">
              CONTINUE
            </button>
          </form>
        </div>
      </div>
    </>
  );
};

export default Shipping;
