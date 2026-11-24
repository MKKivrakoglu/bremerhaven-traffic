// Accordion
let isloggedin = false; 
let acc = document.getElementsByClassName("accordion");
let activeElement;
function system() {

  for (let i = 0; i < acc.length; ++i) {
    acc[i].addEventListener("click", function (e) {

    if (e.target.classList.contains('disabled')) {
        let loginMessage = document.getElementById('login-message');
        loginMessage.innerHTML = "Bitte zuerst einloggen!";
        if (!acc[0].classList.contains('active')) {
          acc[0].click();
        }
        return;
      }

      let activeFound = e.target.classList.contains('active');
      if (activeFound) {
        e.target.classList.remove('active');
        e.target.nextElementSibling.className = 'panel';
      } else {
        activeElement = document.querySelector(".active");
        if (activeElement) {
          activeElement.classList.remove('active');
          activeElement.nextElementSibling.className = 'panel';
        }
        e.target.classList.add('active');
        e.target.nextElementSibling.className = 'panelactive';
      }
    });
  }
}


// Login
function login() {
  const user = document.getElementById('userInput').value;
  const password = document.getElementById('passwordInput').value;
  const url = "cgi-bin/login.sh?" + user + "|" + password;

  let xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState == 4 && xhr.status == 200) {
      isloggedin = true;

    }

    else if (xhr.readyState == 4 && xhr.status == 403) {
      document.getElementById("login-message").innerHTML = "Anmeldedaten sind falsch!";
    }
  };
  xhr.open("GET", url);
  xhr.send();
}


// Intern
function loadIntern() {
  let xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState == 4 && xhr.status == 200) {
      document.getElementById("login-header").innerHTML = "Eingeloggt!";
      document.getElementById("login-area").style.display = "none";
      document.getElementById("logout-btn").style.display = "block";
      acc[1].classList.remove('disabled');
      acc[2].classList.remove('disabled');
    } else if (xhr.readyState == 4 && xhr.status == 303) {
      if (!isloggedin){
        return;
      } else
        logout();
    }

  };

  xhr.open("GET", "cgi-bin/session.sh");
  xhr.send();
}

// Logout
function logout() {
  let xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState == 4 && xhr.status == 200) {
      document.getElementById("login-header").innerHTML = "Ausgeloggt!";
      document.getElementById("login-area").style.display = "block";
      document.getElementById("logout-btn").style.display = "none";

     acc[1].classList.add('disabled');
     acc[2].classList.add('disabled');

      activeElement = document.querySelector(".active");
      if (activeElement) {
        activeElement.classList.remove('active');
        activeElement.nextElementSibling.className = 'panel';
        isloggedin = false;
        document.getElementById("login-message").innerHTML = "";
      }
    }
  };
  xhr.open("GET", "cgi-bin/logout.sh");
  xhr.send();
  //document.getElementById("login-message").style.display = "none";
}

function init() {
  window.setInterval(loadIntern, 1000)
}



window.onload = function() {
  init();
  system();


}
