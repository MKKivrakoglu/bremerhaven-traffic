let map;
let markers = {};    // MMSI -> Marker
let tracks = {};     // MMSI -> Polyline
let ships = {};      // MMSI -> Schiffsdaten (neu bei jedem Laden)
let trackLayer;

window.addEventListener("load", init);

function ladeSchiffe() {
  let xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4 && xhr.status === 200) {
      map.invalidateSize();

      // 1) ships bei jedem Update NEU aufbauen
      let newShips = {};
      let text = xhr.responseText || "";
      text = text.replace(/\r/g, "");
      let lines = text.trim().split("\n");

      for (let i = 0; i < lines.length; i++) {
        let line = lines[i];
        if (!line) continue;

        let parts = line.split("|");
        if (parts.length < 5) continue;

        let mmsi  = parts[0].trim();
        let name  = (parts[1] || "").trim();
        let lat   = parseFloat(parts[2]);
        let lon   = parseFloat(parts[3]);
        let datum = new Date(parts[4].trim());

        if (isNaN(datum.getTime())) datum = new Date();

        if (!newShips[mmsi]) {
          newShips[mmsi] = { name: name, coords: [], lastDatum: datum };
        }
        newShips[mmsi].coords.push([lat, lon]);
        newShips[mmsi].lastDatum = datum;
      }

      // 2) Marker aktualisieren oder neu setzen
      for (let mmsi in newShips) {
        let ship = newShips[mmsi];
        let coords = ship.coords;
        let last = coords[coords.length - 1];

        if (!markers[mmsi]) {
          // neuer Marker
          let marker = L.marker(last).addTo(map);
          marker.bindPopup(
            ship.name + "<br>Letztes Signal: " + ship.lastDatum.toLocaleTimeString(),
            { autoClose: false, closeOnClick: false }
          );

          marker.on("click", function (e) {
            if (tracks[mmsi]) {
              trackLayer.removeLayer(tracks[mmsi]);
              tracks[mmsi] = undefined;
              marker.closePopup();
            } else {
              tracks[mmsi] = L.polyline(ship.coords, {
                color: "blue",
                interactive: false,
                bubblingMouseEvents: false
              }).addTo(trackLayer);
              marker.openPopup();
            }
          });

          markers[mmsi] = marker;
        } else {
          // bestehenden Marker aktualisieren
          let marker = markers[mmsi];
          marker.setLatLng(last);
          marker.getPopup().setContent(
            ship.name + "<br>Letztes Signal: " + ship.lastDatum.toLocaleTimeString()
          );

          // falls Route sichtbar: aktualisieren
          if (tracks[mmsi]) {
            tracks[mmsi].setLatLngs(ship.coords);
          }
        }
      }

      // 3) Alte Schiffe entfernen (älter als 5 Minuten oder nicht mehr im Datensatz)
      let now = new Date();
      for (let mmsi in markers) {
        let ship = newShips[mmsi];
        if (!ship) {
          // Schiff nicht mehr vorhanden -> löschen
          map.removeLayer(markers[mmsi]);
          delete markers[mmsi];
          if (tracks[mmsi]) {
            trackLayer.removeLayer(tracks[mmsi]);
            delete tracks[mmsi];
          }
          continue;
        }

        let diffMinutes = (now - ship.lastDatum) / 60000;
        if (diffMinutes > 5) {
          map.removeLayer(markers[mmsi]);
          delete markers[mmsi];
          if (tracks[mmsi]) {
            trackLayer.removeLayer(tracks[mmsi]);
            delete tracks[mmsi];
          }
        }
      }

      // 4) Neue Ships-Struktur übernehmen
      ships = newShips;
    }
  };

  xhr.open("GET", "cgi-bin/Schiffsdaten.sh", true);
  xhr.send();
}

function init() {
  map = L.map('map', { closePopupOnClick: false }).setView([53.55, 8.55], 12);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: "© OpenStreetMap"
  }).addTo(map);

  trackLayer = L.layerGroup().addTo(map);

  ladeSchiffe();
  setInterval(ladeSchiffe, 1000);
}

