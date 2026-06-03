import React, { useState, useEffect } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";

const LocationFilter = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();

  const [status, setStatus] = useState("idle"); // idle | requesting | detected | denied | error
  const [areaLabel, setAreaLabel] = useState("");

  // On mount, if pinCode already in URL (from a previous detection), show it
  useEffect(() => {
    const existing = searchParams.get("pinCode");
    if (existing) {
      setAreaLabel(existing);
      setStatus("detected");
    }
  }, []);

  const detectLocation = () => {
    if (!navigator.geolocation) {
      setStatus("error");
      return;
    }

    setStatus("requesting");

    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        const { latitude, longitude } = pos.coords;
        try {
          const res = await fetch(
            `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`,
            { headers: { "Accept-Language": "en" } }
          );
          const data = await res.json();
          const pinCode = data?.address?.postcode;

          if (pinCode) {
            const area =
              data?.address?.suburb ||
              data?.address?.neighbourhood ||
              data?.address?.town ||
              data?.address?.city ||
              pinCode;

            setAreaLabel(`${area} (${pinCode})`);
            setStatus("detected");
            navigate(`/?pinCode=${pinCode}`);
          } else {
            setStatus("error");
          }
        } catch {
          setStatus("error");
        }
      },
      (err) => {
        if (err.code === err.PERMISSION_DENIED) {
          setStatus("denied");
        } else {
          setStatus("error");
        }
      },
      { timeout: 10000 }
    );
  };

  const clearLocation = () => {
    setStatus("idle");
    setAreaLabel("");
    navigate("/");
  };

  return (
    <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
      {status === "idle" && (
        <button
          className="btn btn-sm btn-outline-light"
          onClick={detectLocation}
          title="Show products near you"
        >
          <i className="fa fa-map-marker" aria-hidden="true" /> &nbsp;
          Use My Location
        </button>
      )}

      {status === "requesting" && (
        <span className="text-white" style={{ fontSize: "0.85rem" }}>
          <span
            className="spinner-border spinner-border-sm me-1"
            role="status"
          />
          Detecting...
        </span>
      )}

      {status === "detected" && (
        <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
          <span
            className="badge bg-success"
            style={{ fontSize: "0.78rem", maxWidth: "160px", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}
            title={areaLabel}
          >
            <i className="fa fa-map-marker me-1" />
            {areaLabel}
          </span>
          <button
            className="btn btn-sm btn-outline-light py-0 px-1"
            onClick={clearLocation}
            title="Clear location filter"
            style={{ fontSize: "0.75rem" }}
          >
            ✕
          </button>
        </div>
      )}

      {status === "denied" && (
        <span className="text-warning" style={{ fontSize: "0.8rem" }}>
          <i className="fa fa-exclamation-triangle me-1" />
          Location denied.{" "}
          <button
            className="btn btn-link p-0 text-warning"
            style={{ fontSize: "0.8rem" }}
            onClick={detectLocation}
          >
            Retry
          </button>
        </span>
      )}

      {status === "error" && (
        <span className="text-warning" style={{ fontSize: "0.8rem" }}>
          Location unavailable.{" "}
          <button
            className="btn btn-link p-0 text-warning"
            style={{ fontSize: "0.8rem" }}
            onClick={detectLocation}
          >
            Retry
          </button>
        </span>
      )}
    </div>
  );
};

export default LocationFilter;
