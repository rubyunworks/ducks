
function remote_ajax_call() {
  var req = new XMLHttpRequest();
  req.open("GET", "http://localhost/addr?cardID=32", /*async*/true);
  req.onreadystatechange = myHandler;
  req.send(/*no params*/null);
}


