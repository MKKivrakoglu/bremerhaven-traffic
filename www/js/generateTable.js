window.addEventListener("load", function() {
  generate();
  setInterval(generate, 1000);
});

function generate() {
  let xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4 && xhr.status === 200) {
      let tbody = document.querySelector("#ships tbody");
      tbody.innerHTML = "";

      let lines = xhr.responseText.trim().split("\n");

      for (let i = 0; i < lines.length; i++) {
        let cols = lines[i].split("|");
        let tr = document.createElement("tr");

        for (let j = 0; j < cols.length; j++) {
          let td = document.createElement("td");
          td.textContent = cols[j] === "NULL" ? "" : cols[j];
          tr.appendChild(td);
        }

        tbody.appendChild(tr);
      }
    }
  };

  xhr.open("GET", "cgi-bin/generateTable.sh", true);
  xhr.send();
}

