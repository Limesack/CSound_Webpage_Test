/*!
* Start Bootstrap - Simple Sidebar v6.0.3 (https://startbootstrap.com/template/simple-sidebar)
* Copyright 2013-2021 Start Bootstrap
* Licensed under MIT (https://github.com/StartBootstrap/startbootstrap-simple-sidebar/blob/master/LICENSE)
*/
// 
// Scripts
// 

window.addEventListener('DOMContentLoaded', event => {

    // Toggle the side navigation
    const sidebarToggle = document.body.querySelector('#sidebarToggle');
    if (sidebarToggle) {
        // Uncomment Below to persist sidebar toggle between refreshes
        // if (localStorage.getItem('sb|sidebar-toggle') === 'true') {
        //     document.body.classList.toggle('sb-sidenav-toggled');
        // }
        sidebarToggle.addEventListener('click', event => {
            event.preventDefault();
            document.body.classList.toggle('sb-sidenav-toggled');
            localStorage.setItem('sb|sidebar-toggle', document.body.classList.contains('sb-sidenav-toggled'));
        });
    }

});


const label_links = {
    "Pedestrian beep": "pedestrian_beep.html",
    "Police": "police.html",
    "Phone Tone": "phone_tone.html",
    "Wind": "wind.html",
    "Fire": "fire.html",
    "example2": "example2.html",
    "example3": "example3.html",
    "example4": "example4.html",
    "example5": "example6.html",
  };
  Object.entries(label_links).forEach(function([label, link]){
    var button = document.createElement("a");
    button.innerHTML = label;
    button.classList.add("btn");
    button.classList.add("btn-model");
    button.classList.add("mr-1");
  
    button.href = link;
    // 2. Append somewhere
    var body = document.getElementsByClassName("container-fluid")[1];
    body.appendChild(button);
  });
