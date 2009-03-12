// Cherry Templates jQuery Plugin.
//
//   data = {
//     hello: "Hello, World!"
//   }
//
//   $.cherry(data)
//
// Cherry templates are especially useful when filled via AJAX JSON.

jQuery.cherry_ajax = function(url) {
  jQuery.getJSON(url, jQuery.cherry);
};

jQuery.cherry = function(data) {
  jQuery('body').interpolate(data);
};

// Interpolate data into template nodes.

jQuery.fn.interpolate = function(data) {
  if(!data) {
    this.remove();
  }
  else if (data instanceof Array) {
    this.interpolate_array(data);
  }
  else if(data instanceof Object) {
    this.interpolate_object(data);
  }
  else {
    this.interpolate_value(data);
  };
  return this;
};

// Interpolate object mapping.

jQuery.fn.interpolate_object = function(data) {
  var qry;
  var attr;
  var css;
  var result;

  for (var id in data) {
    attr = false;
    css  = false;
    qry  = id;

    result = qry.match(/^<(.*?)>$/);
    if (result != null) {
      css = true;
      qry = result[1];
    };

    result = qry.match(/^((.*?)\/)?([@](.*?))$/);
    if (result != null) {
      if (result[2] == undefined) { result[2] = "" };
      attr = result[4];
      qry  = result[2] + '[@' + attr + ']';
    }
    else {
      attr = false;
    };

    if (css == false) {
      qry = '#' + qry;
    };

    if (attr == false) {
      // probably change to use 'ref' attribute instead of 'id'
      this.find(qry).interpolate(data[id]);
    }
    else {
      //qry = qry + '[@' + attr + ']';
      this.find(qry).attr(attr,data[id]);
    };
  };
};

// Interpolate array sequence.

jQuery.fn.interpolate_array = function(data) {
  var temp = this.clone();
  this.empty();
  for (var i in data) {
    var newNode = temp.clone();
    newNode.interpolate(data[i]);
    this.append(newNode.children());
  };
};

// Interpolate value.
//
// This has some special HTML features.
//
// TODO Should we have two modes --one with and one
// without the extra HTML features?

jQuery.fn.interpolate_value = function(data) {
  //var all_special = new Array;

  // text inputs
  //var special = this.find('input[@type=text]');
  //special.val(data.toString());
  //all_special.concat(special);
  // textarea
  // TODO

  //this.not(special).empty();
  //this.not(special).append(data.toString());
//alert(data);
  this.empty();
  this.append(data.toString());
};






/*
// Interpolate list.

function interpolate_list(node, data) {
  temp = node.copy(true)
  node.empty!
  for (var d in data) {
    nc = temp.copy(true);
    interpolate_children( nc, d )
    for (var c in nc.children) {
      node.add(c);
    };
  };
};
*/