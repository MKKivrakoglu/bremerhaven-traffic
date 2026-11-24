function system() {

  let acc = document.getElementsByClassName("accordion");

  for (let i = 0; i < acc.length; ++i) {
    acc[i].addEventListener("click", function(e){
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
        let activeElement = document.querySelector(".active");
        
        if (activeElement){
          activeElement.classList.remove('active')
          activeElement.nextElementSibling.className='panel'
        }
        
        e.target.classList.add('active')
        e.target.nextElementSibling.className = 'panelactive'
      }
    });
  }
}

window.onload = system
