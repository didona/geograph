var refreshEnabled = false;
var refreshInterval = null;
var refreshTime = 5;

function switchRefresh() {
  var buttonText = "stop refresh";
  if(refreshEnabled) {
    clearInterval(refreshInterval);
    buttonText = "start refresh";
  } else {
    refreshInterval = setInterval(refreshMap, refreshTime * 1000);
  }
  refreshEnabled = !refreshEnabled;
  $("#refresh-button span").html(buttonText);
}

function refreshMap() {
  $.ajax({url:'landmarks_map', dataType:'script'});
}

function changeRefresh(time) {
  refreshTime = time;
  if(refreshEnabled) {
    clearInterval(refreshInterval);
    refreshInterval = setInterval(refreshMap, refreshTime * 1000);
  }
}

var map = null;
var markers = new Hash();
var infoWindows = {};
var currentLocations = new Hash();
var currentEdges = new Hash();
var currentCycle = 0;
var mapEdges = new Hash();
var mapCenterLat = 41.9;
var mapCenterLng = 12.4;
var infoWindowTemplate = '<div id="content-{LOCATIONID}"><h2 id="content-heading-{LOCATIONID}">{LOCATIONTYPE}</h2><div id="body-content-{LOCATIONID}">{LOCATIONDATA}</div></div>';

function initializeMap() {
  var latlng = new google.maps.LatLng(mapCenterLat, mapCenterLng);
  var myOptions = {
    zoom:2,
    center:latlng,
    mapTypeId:google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

}

function addLocations(locations) {
  locations.each(function(location) {
    currentLocations[location.id] = location;
    addLocation(location);
  });
}

function addLocation(location) {
  //console.info("Received new geoobject:");
  //console.info(JSON.stringify(location));
  if(location == null || location.data.type == null) {
    console.warn("Invalid Location, ignoring");
    return;
  }
  //var latlng = new google.maps.LatLng(mapCenterLat + (location.latitude/100), mapCenterLng + (location.longitude/100));
  var latlng = new google.maps.LatLng(location.latitude, location.longitude);
 // console.info("-----------");

  markers[location.id] = new google.maps.Marker({
    position:latlng,
    map:map,
    //animation: google.maps.Animation.DROP,
    title:"Location: " + location.id
  });
  // centerMap(latlng);

  //console.info("Added new marker:");

  var icon = null;
  if(location.data.type == "Mover") {
    icon = '/assets/bike.png';
  } else if(location.data.type == "Post") {
    icon = '/assets/post.png';
  } else if(location.data.type == "Track") {
    icon = '/assets/track.png';
  } else if(location.data.type == "Landmark") {
    //icon = '/assets/post.png';
  }

  if(icon == null) {
    return;
  }

  //console.info("Type checked");
  if(icon != null) markers[location.id].setIcon(icon);

  addInfoWindow(location, markers[location.id]);
}

function addInfoWindow(location, marker) {
  var infoWindowContent = infoWindowSource(location);
  var infoWindow = new google.maps.InfoWindow({
    content:infoWindowContent
  });
  google.maps.event.addListener(marker, 'click', function() {
    infoWindow.open(map, marker);
  });
  infoWindows[location.id] = infoWindow;
}

function updateInfoWindow(location) {
  var infoWindowContent = infoWindowSource(location);
  infoWindows[location.id].setContent(infoWindowContent);
}

function infoWindowSource(location) {
  var infoWindowContent = infoWindowTemplate.replace(/{LOCATIONID}/g, location.id);
  infoWindowContent = infoWindowContent.replace(/{LOCATIONTYPE}/g, location.data['type']);
  infoWindowContent = infoWindowContent.replace(/{LOCATIONDATA}/g, location.data['body']);
  return infoWindowContent;
}

function moveLocation(location) {
  //var latlng = new google.maps.LatLng(mapCenterLat + (location.latitude/100), mapCenterLng + (location.longitude/100));
  var latlng = new google.maps.LatLng(location.latitude, location.longitude);
  markers[location.id].setPosition(latlng);
  //markers[location.id].setAnimation(google.maps.Animation.DROP);
  //markers[location.id].setAnimation(google.maps.Animation.BOUNCE);
  //setTimeout(function() {markers[location.id].setAnimation(null);}, 500);
  //centerMap(latlng);

  updateInfoWindow(location);
}

function destroyLocation(location) {
  if(markers.get(location.id) == null) return;
  markers[location.id].setMap(null);
  markers[location.id] = null;
}

function destroyLocations(ids) {
  ids.each(function(_id) {
    markers[_id].setMap(null);
    markers[_id] = null;
  });
}

function destroyAllLocations() {
  markers.each(function(value, key) {
    value.setMap(null);
    value = null;
  });
  markers = new Hash();
}

function onPercept(perception) {
  var location = perception["data"];

  if(perception["header"]["action"] == "actions::destroy_action") {
    destroyLocation(location);
    return;
  }

  if(perception["header"]["action"] == "actions::destroy_posts_action") {
    destroyLocations(location.ids);
    return;
  }

  if(markers[location.id] != undefined) {
    moveLocation(location);
  } else {
    addLocation(location);
  }
}

function onPostsReadPercept(perception) {
  var posts = perception['data'];
  posts.each(function(post) {
    if(markers[post.id] != null) {
      markers[post.id].setAnimation(google.maps.Animation.BOUNCE);
      setTimeout(function() {
        markers[post.id].setAnimation(null);
      }, 2000);
    }
  });
}

function onEdgesPercept(perception) {
  //removeAllEdges();
  //try{
  var edges = perception["data"];
  edges.each(function(edge) {
    removeEdge(edge);
  });
  edges.each(function(edge) {
    addEdge(edge);
  });
  //} catch(err) {
  //  $log(err.stack);
  //}
}

function addEdges(edges) {
  edges.each(function(edge) {
    currentEdges[edgeIndex(edge)] = edge;
    addEdge(edge);
  });  
}

function addEdge(edge) {
  //$log(JSON.stringify(edge));

  var edgeCoordinates = [
    new google.maps.LatLng(edge.from.latitude, edge.from.longitude),
    new google.maps.LatLng(edge.to.latitude, edge.to.longitude)
  ];

  var edgePath = new google.maps.Polyline({
    path:edgeCoordinates,
    strokeColor:"#FF0000",
    strokeOpacity:1.0,
    strokeWeight:2
  });

  edgePath.setMap(map);
  var edgeIdx = edgeIndex(edge);
  if(mapEdges[edgeIdx] == null) {
    mapEdges[edgeIdx] = [];
  }

  mapEdges[edgeIdx].push(edgePath);
}

function edgeIndex(edge) {

  var sortedIds = [edge.from.id, edge.to.id].sort();
  var index = "";
  sortedIds.each(function(id) {
    return index += id;
  });
  return index;
}

function removeEdge(edge) {
  var edgeIdx = edgeIndex(edge);
  if(mapEdges[edgeIdx] == undefined) return;
  mapEdges[edgeIdx].each(function(mEdge) {
    mEdge.setMap(null);
    mEdge = null;
  });
  mapEdges[edgeIdx] = [];
}

function removeAllEdges() {
  mapEdges.each(function(mEdge) {
    mEdge.setMap(null);
    mEdge = null;
  });
  mapEdges = [];
}

function centerMap(latLng) {
  var bounds = new google.maps.LatLngBounds();
  bounds.extend(latLng);
  map.fitBounds(bounds);
  map.setZoom(8);
}


function refreshEdges(freshEdges) {
  freshEdges.each(function(edge) {
    var _edgeIndex = edgeIndex(edge);
    var existingEdge = currentEdges.get(_edgeIndex);
    // if the edge exists update its position if changed
    if(existingEdge != null) {
      if(edgeChanged(existingEdge, edge)) {
        removeEdge(edge);
        addEdge(edge);
        currentEdges[_edgeIndex] = edge;
      }
      currentEdges[_edgeIndex]['exists_at_cycle'] = currentCycle;
    } else {
      // if the edge don't exists create it
      addEdge(edge);
      currentEdges[_edgeIndex] = edge;
      currentEdges[_edgeIndex]['exists_at_cycle'] = currentCycle;
    }
  });

  // remove edges that not exists in the fresh data
  currentEdges.each(function(edge, key) {
    if(edge['exists_at_cycle'] < currentCycle) {
      removeEdge(edge);
      currentEdges.erase(key);
    }
  });
  currentCycle++;
}

function edgeChanged(edgeA, edgeB) {
  return(
    (edgeA.from.latitude != edgeB.from.latitude) ||
      (edgeA.from.longitude != edgeB.from.longitude) ||
      (edgeA.to.latitude != edgeB.to.latitude) ||
      (edgeA.to.longitude != edgeB.to.longitude)
    )
}

function locationChanged(goA, goB) {
  return(
    (goA.latitude != goB.latitude) ||
      (goA.longitude != goB.longitude) || 
      (goA.data.type != goB.data.type)
    );
}


function refreshLocations(freshLocations) {
  freshLocations.each(function(location) {
    //console.info("received from server:");
    //console.info(JSON.stringify(location));
    var existingLocation = currentLocations.get(location.id);
    // if the location exists update its position if changed    
    if(existingLocation != null) {
      if(locationChanged(existingLocation, location)) {
        destroyLocation(existingLocation);
        addLocation(location);
        currentLocations[location.id] = location;
      }
      currentLocations[location.id]['exists_at_cycle'] = currentCycle;
    } else {
      // if the geo object don't exists create it
      addLocation(location);
      currentLocations[location.id] = location;
      currentLocations[location.id]['exists_at_cycle'] = currentCycle;
    }
  });

  // remove geo objects that not exists in the fresh data
  currentLocations.each(function(location, key) {
    if(location['exists_at_cycle'] < currentCycle) {
      destroyLocation(location);
      currentLocations.erase(key);
    }
  });
  //    currentCycle++;
}


function slideRefresh() {
  $('.refresh-slider').slider({
    min:1,
    max:60,
    step:1,
    value:refreshTime,
    create:function(event, ui) {
      $(this).slider('value', refreshTime);
    },
    slide:function(event, ui) {
      $("#refresh-label").html(ui.value);
      changeRefresh(ui.value);
    }
  });
}