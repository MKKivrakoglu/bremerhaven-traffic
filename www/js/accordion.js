function system() {

  let acc = document.getElementsByClassName("accordion");

  for (let i = 0; i < acc.length; ++i) {
    acc[i].addEventListener("click", function(e){
      console.log("ge", e.target)
      console.log(e.target.classList)
      let activeFound = false
      for (let j = 0; j < e.target.classList.length; ++j){
        console.log(e.target.classList[j])
        if (e.target.classList[j] == 'active'){
          console.log("spezial class found")
          activeFound = true
        }
      }
      if (activeFound) {
        e.target.classList.remove('active')
        e.target.nextElementSibling.className='panel'
      } else {
        e.target.classList.add('active')
        e.target.nextElementSibling.className = 'panelactive'
      }
    });
  }
}

window.onload = system
      


function login(){
        const user = document.getElementById('userInput').value;
        const password = document.getElementById('passwordInput').value;

         console.log("User:", user);
  console.log("Password:", password);
  alert("Sende: " + user + " / " + password);

      //  const url = "cgi-bin/login1.sh?user=" + user + "&password=" + password;

        const url = "cgi-bin/login.sh?" + user + "|" +  password;


        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function (){
          if(xhr.readyState == 4 && xhr.status == 200){
            document.getElementById("header").innerHTML = "Eingeloggt!";
            document.getElementById("login-area").style.display = "none";
            document.getElementById("intern-area").style.display = "block";
            loadIntern(); // Inhalte laden
          }
        };
        xhr.open("GET", url);
        xhr.send();
      }

      // Interne Inhalte laden
      function loadIntern(){
        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function (){
          if(xhr.readyState == 4 && xhr.status == 200){
            // Falls intern.sh gültige Antwort gibt → Inhalte einfügen
            document.getElementById("intern-content").innerHTML = xhr.responseText;
            document.getElementById("header").innerHTML = "Eingeloggt!";
            document.getElementById("login-area").style.display = "none";
            document.getElementById("intern-area").style.display = "block";
          }
          else if(xhr.readyState == 4 && xhr.status == 303){
            // Falls intern.sh Redirect macht → zurück zur Login-Maske
            document.getElementById("header").innerHTML = "Bitte einloggen!";
            document.getElementById("intern-area").style.display = "none";
            document.getElementById("login-area").style.display = "block";
          }
        };
        xhr.open("GET", "cgi-bin/intern.sh");
        xhr.send();
      }

      // Logout-Funktion
      function logout(){
        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function (){
          if(xhr.readyState == 4 && xhr.status == 200){
            document.getElementById("header").innerHTML = "Ausgeloggt!";
            document.getElementById("intern-area").style.display = "none";
            document.getElementById("login-area").style.display = "block";
          }
        };
        xhr.open("GET", "cgi-bin/logout.sh");
        xhr.send();
      }

      // Prüfen beim Laden der Seite
      window.onload = function(){
        loadIntern(); // direkt Session prüfen
      };
