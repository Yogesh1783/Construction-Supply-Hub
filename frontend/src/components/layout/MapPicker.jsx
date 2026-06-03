import { useState, useRef } from "react";
import { MapContainer, TileLayer, Marker, useMapEvents, useMap } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
  iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
});

function ClickHandler({ onLocationSelect }) {
  useMapEvents({
    click(e) {
      onLocationSelect(e.latlng.lat, e.latlng.lng);
    },
  });
  return null;
}

function FlyToLocation({ target }) {
  const map = useMap();
  if (target) {
    map.flyTo([target.lat, target.lng], 14, { animate: true, duration: 1.2 });
  }
  return null;
}

const MapPicker = ({ lat, lng, onLocationSelect }) => {
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [searching, setSearching] = useState(false);
  const [flyTarget, setFlyTarget] = useState(null);
  const debounceRef = useRef(null);

  const handleQueryChange = (e) => {
    const val = e.target.value;
    setQuery(val);

    clearTimeout(debounceRef.current);
    if (!val.trim()) { setSuggestions([]); return; }

    debounceRef.current = setTimeout(async () => {
      setSearching(true);
      try {
        const res = await fetch(
          `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(val)}&limit=5`,
          { headers: { "Accept-Language": "en" } }
        );
        const data = await res.json();
        setSuggestions(data);
      } catch {
        setSuggestions([]);
      } finally {
        setSearching(false);
      }
    }, 400);
  };

  const handleSuggestionClick = (place) => {
    const newLat = parseFloat(place.lat);
    const newLng = parseFloat(place.lon);
    setFlyTarget({ lat: newLat, lng: newLng });
    onLocationSelect(newLat, newLng);
    setQuery(place.display_name);
    setSuggestions([]);
  };

  const position = lat && lng ? [lat, lng] : [20.5937, 78.9629];

  return (
    <div style={{ width: "100%" }}>
      {/* Search box */}
      <div style={{ position: "relative", marginBottom: "8px" }}>
        <div style={{ display: "flex", gap: "6px" }}>
          <input
            type="text"
            className="form-control"
            placeholder="Search location (e.g. Mumbai, Connaught Place...)"
            value={query}
            onChange={handleQueryChange}
          />
          {searching && (
            <span
              className="spinner-border spinner-border-sm text-primary"
              style={{ alignSelf: "center", flexShrink: 0 }}
            />
          )}
        </div>

        {/* Suggestions dropdown */}
        {suggestions.length > 0 && (
          <ul
            className="list-group"
            style={{
              position: "absolute",
              top: "100%",
              left: 0,
              right: 0,
              zIndex: 1000,
              maxHeight: "200px",
              overflowY: "auto",
              boxShadow: "0 4px 12px rgba(0,0,0,0.15)",
            }}
          >
            {suggestions.map((place) => (
              <li
                key={place.place_id}
                className="list-group-item list-group-item-action"
                style={{ cursor: "pointer", fontSize: "0.85rem" }}
                onClick={() => handleSuggestionClick(place)}
              >
                {place.display_name}
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* Map */}
      <div style={{ height: "300px", width: "100%", borderRadius: "8px", overflow: "hidden", zIndex: 0 }}>
        <MapContainer
          center={position}
          zoom={lat ? 13 : 5}
          style={{ height: "100%", width: "100%" }}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <ClickHandler onLocationSelect={onLocationSelect} />
          <FlyToLocation target={flyTarget} />
          {lat && lng && <Marker position={[lat, lng]} />}
        </MapContainer>
      </div>
    </div>
  );
};

export default MapPicker;
