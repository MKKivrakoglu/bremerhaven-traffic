// Accordion
//let loginMessage;
let isloggedin = false;
function system() {
  let acc = document.getElementsByClassName("accordion");

  for (let i = 0; i < acc.length; ++i) {
    acc[i].addEventListener("click", function (e) {
      if (e.target.classList.contains('disabled')) {
         loginMessage = document.getElementById('login-message');
        if (loginMessage) {
         loginMessage.textContent = "Bitte zuerst einloggen!";
        }
        const loginAccordion = document.querySelectorAll('.accordion')[0];
        if (loginAccordion && !loginAccordion.classList.contains('active')) {
          loginAccordion.click();
        }
        return;
      }

      let activeFound = e.target.classList.contains('active');
      if (activeFound) {
        e.target.classList.remove('active');
        e.target.nextElementSibling.className = 'panel';
      } else {
        let activeElement = document.querySelector(".active");
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
      //isLoggedIn = true;
     // document.getElementById("login-header").innerHTML = "Anmelden";
     // document.getElementById("login-area").style.display = "none";
      //document.getElementById("logout-btn").style.display = "block";
      isloggedin = true;
      //init();
    //  loadIntern();



     // console.log(xhr.responslogin-message;
    }
      else if (xhr.readyState == 4 && xhr.status == 403) {
      document.getElementById("login-message").innerHTML = "anmeldedaten falsch!";
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

      const mapButton = document.querySelectorAll('.accordion')[1];
      const infoButton = document.querySelectorAll('.accordion')[2];
      mapButton.classList.remove('disabled');
      infoButton.classList.remove('disabled');
      
      //init();
    } else if (xhr.readyState == 4 && xhr.status == 303) {
      if (!isloggedin) {
        return;
      } else
       // isloggedin = false;
        logout();
       // document.getElementById("login-message").innerHTML = "Deine Session ist abgelaufen!";
    }
   
  };
  xhr.open("GET", "cgi-bin/session.sh");
  xhr.send();
  console.log("bin am laufen");
}

// Logout
function logout() {
  let xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState == 4 && xhr.status == 200) {
      document.getElementById("login-header").innerHTML = "Ausgeloggt!";
      document.getElementById("login-area").style.display = "block";
      document.getElementById("logout-btn").style.display = "none";

      const mapButton = document.querySelectorAll('.accordion')[1];
      const infoButton = document.querySelectorAll('.accordion')[2];
      mapButton.classList.add('disabled');
      infoButton.classList.add('disabled');

      const activeElement = document.querySelector(".active");
      if (activeElement) {
        activeElement.classList.remove('active');
        activeElement.nextElementSibling.className = 'panel';
        isloggedin = false;
          document.getElementById("login-message").style.display = "none";
      }
    }
  };
  xhr.open("GET", "cgi-bin/logout.sh");
  xhr.send();
}

/*  function oncePerSecond() {
  let xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if (xhr.readyState == 4 && xhr.status == 200) {
      console.log("Session läuft ");
      }
    }
    xhr.open("GET", "cgi-bin/session.sh");
  xhr.send();
  console.log("es hat geklappt");
  };*/

function init() {
  window.setInterval(loadIntern, 1000);
}

/*function init() {
  if (!isloggedin) {
    //logout();
    return;
  } else if (isloggedin) { 
  window.setInterval(loadIntern, 1000);
  }
}*/

window.onload = function() {
  init();
  system();
}

/*window.addEventListener("load", function () {
  system();
  init();
 // loadIntern();
  
});*/

