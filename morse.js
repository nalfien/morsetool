var txt2morse = [];
var morse2txt = [];
				
var plays = {
	".": "1",
	"-": "3",
}

$.getJSON("morseJSON.json", function(json) {
	$.each(json, function(key, value) {
		txt2morse[key] = value;
		morse2txt[value] = key;
	});
});

function t2m(textStr) {
	var output = "";
	
	$.each(textStr.toLowerCase().split(''), function(idx, key) {
		if(typeof txt2morse[key] != "undefined") {
			if(!output.endsWith("/ ") || txt2morse[key] != "/") {
				output += txt2morse[key] + " ";
			}
		} else {
			output += "*";
		}
	});
	
	return output;
}

function m2t(morseStr) {
	var output = "";
	
	$.each(morseStr.split(' '), function(idx, key) {
		if(key != "") {
			if(typeof morse2txt[key] != "undefined") {
				output += morse2txt[key].toUpperCase();
			} else {
				output += "*";
			}								
		}
	});
	
	return output;
}

function getUrl(urlToGet) {
	var output = [];
	$.ajax({
		type: "POST",
		url: "morse.php",
		data: { url: urlToGet },
		dataType: "text",
		async: false,
		success: function(text) {
			output.push(text);
			output.push(t2m(text));
		},
		error: {},
	});
	
	return output;
}