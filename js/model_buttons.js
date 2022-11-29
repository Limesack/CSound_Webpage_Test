const label_links = {
    "Pedestrian beep": "pedestrian_beep.html",
    "Police": "police.html",
    "Phone Tone": "phone_tones.html",
    "Wind": "wind.html",
    "Fire": "fire.html",
//    "example2": "example2.html",
//    "example3": "example3.html",
//    "example4": "example4.html",
//    "example5": "example6.html",
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
