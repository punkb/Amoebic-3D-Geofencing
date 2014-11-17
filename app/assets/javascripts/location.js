

function getUserLocation() { 

//check if the geolocation object is supported, if so get position
if (navigator.geolocation)
	navigator.geolocation.getCurrentPosition(displayLocation, displayError, {enableHighAccuracy: true});
else
	document.getElementById("locationData").innerHTML = "Sorry - your browser doesn't support geolocation!";
}



function displayLocation(position) { 

//build text string including co-ordinate data passed in parameter
var displayText = "User latitude is " + position.coords.latitude + " longitude is " + position.coords.longitude + " and altitude is " + position.coords.altitude ;
var loc = [[position.coords.latitude, position.coords.longitude], [position.coords.altitude]]
var lat = position.coords.latitude;
var lng = position.coords.longitude;
 // var a = new Timestamp();

// var loc = [[position.coords.latitude, position.coords.longitude][position.coords.altitude]]

//display the string for demonstration
// document.getElementById("locationData").innerHTML = displayText;
// $.post('/place',{lat:position.coords.latitude, lng:position.coords.longitude});
$.post('/places/create',{lat: position.coords.latitude, 
						 lng: position.coords.longitude, 
						  alt:position.coords.altitude
						 // time:a
						});


if (position.coords.altitude == null) {
	var text = "Null"

}else {
	var text = "Something"
}
document.getElementById("locationData").innerHTML = loc + text;


}




function displayError(error) { 

//get a reference to the HTML element for writing result
var locationElement = document.getElementById("locationData");

//find out which error we have, output message accordingly
switch(error.code) {
case error.PERMISSION_DENIED:
	locationElement.innerHTML = "Permission was denied";
	break;
case error.POSITION_UNAVAILABLE:
	locationElement.innerHTML = "Location data not available";
	break;
case error.TIMEOUT:
	locationElement.innerHTML = "Location request timeout";
	break;
case error.UNKNOWN_ERROR:
	locationElement.innerHTML = "An unspecified error occurred";
	break;
default:
	locationElement.innerHTML = "Who knows what happened...";
	break;
}}

