<html>
	<head>
		<title>Morse Page</title>
		<script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
		<script src="morse.js"></script>
		<!--script src="querystring.js"></script-->
		<script>
			$(document).ready(function() {
				var keyTime = 0;
				var keyUp = false;
				var morseOut = "";
				var unit;
				
				$(".outputarea").hide();
				$("#controlDiv").hide();
				
				doWpm();
				
				$("#plaintext").bind('input propertychange', function() {
					$("#morsetext").val("");
					
					$("#morsetext").val(t2m($("#plaintext").val()));
				});
				
				$("#morsetext").bind('input propertychange', function() {
					$("#plaintext").val("");
					
					$("#morsetext").val($("#morsetext").val().replace(/,/g,"-"));
					
					$("#plaintext").val(m2t($("#morsetext").val()));
				});
				
				$("#controlselect").change(function() {
					$(".outputarea").hide();
					$("#" + $("#controlselect option:selected").val()).show();
					
					$("#controlDiv").show();
				});
				
				$("#geturl").click(function() {
					var urlText = getUrl($("#url2load").val());
					$("#plaintext").val(urlText[0]);
					$("#morsetext").val(urlText[1]);
				});
				
				$("#wpmbox").blur(function() {
					doWpm();
				});
				
				function doWpm() {
					var wpm;
						
					if($("#wpmbox").val() != "") {
						wpm = $("#wpmbox").val();
					} else {
						wpm = 10;
					}
					
					unit = 1200 / wpm;
				}
				
				$("#transmitarea").keydown(function(e) {
					e.preventDefault();
					if(e.keyCode == 32) {
						doTransmitOn(e);
					//if(e.keyCode == 32 && !keyUp) {
						/*if(keyTime != 0) {
							var elapsed = $.now() - keyTime;
							
							if(elapsed >= (3 * unit)) {
								if(elapsed < (7 * unit)) {
									morseOut += " ";
								} else {
									morseOut += " / ";
								}
							}
						}
						
						doPrint();
						
						keyTime = $.now();
						keyUp = true;
						doPlay(true);*/
					}
				});
				
				$("#transmitarea").keyup(function(e) {
					e.preventDefault();
					if(e.keyCode == 32) {
						doTransmitOff(e);
					}
				});
				
				$("#mobilebutton").mousedown(function(e) {
					e.preventDefault();
					doTransmitOn(e);
				});
				
				$("#mobilebutton").mouseup(function(e) {
					e.preventDefault();
					doTransmitOff(e);
				});
				
				function doTransmitOn(e) {
					if(!keyUp) {
						if(keyTime != 0) {
							var elapsed = $.now() - keyTime;
							
							if(elapsed >= (3 * unit)) {
								if(elapsed < (7 * unit)) {
									morseOut += " ";
								} else {
									morseOut += " / ";
								}
							}
						}
						
						doPrint();
						
						keyTime = $.now();
						keyUp = true;
						doPlay(true);
					}
				}
				
				function doTransmitOff(e) {
					var thisTime = $.now();
					var elapsed = thisTime - keyTime;
					
					if(elapsed > unit) {
						morseOut += "-";
					} else {
						morseOut += ".";
					}
					
					doPrint();
					
					keyUp = false;
					keyTime = thisTime;
					doPlay(false);
				}
				
				function doPrint() {
					$("#transmitarea").val(morseOut + "\n" + m2t(morseOut));
				}
				
				$("#clearButton").click(function() {
					$("textarea").val("");
					morseOut = "";
					keyTime = 0;
					keyUp = false;
				});
				
				var context = new AudioContext();
				var vco = context.createOscillator();
				vco.type = 'sine';
				vco.frequency.value = $("#soundfreq").val();
				
				vco.start(0);
				
				var vca;
				vca = context.createGain();
				vca.gain.value = 0;
				
				vco.connect(vca);
				vca.connect(context.destination);
				
				$("#playButton").click(function() {
					var totalTime = 0;
					var delays = [0];
					
					$.each($("#morsetext").val().split(''), function(idx, key) {
						if(key != "*") {
							var delay = 2;
							var onOff = false;
							if(typeof plays[key] != "undefined") {
								delay = plays[key];
								onOff = true;
							}
							
							delays[delays.length] = {delay : (delay * unit) + totalTime,
													 play : onOff};
								
							totalTime += (delay * unit);
							
							delays[delays.length] = {delay : unit + totalTime, play : false};
							
							totalTime += unit;
						}
					});
					
					doPlay(true);
					
					$.each(delays, function(idx, key) {
						var onOff;
						if(idx < delays.length - 1) {
							onOff = delays[idx + 1].play;
						} else {
							onOff = false;
						}
						
						setTimeout(doPlay, key.delay, onOff);
					});
					
					doPlay(false);
				});
				
				function doPlay(playState) {
					var change;
					var gain;
					
					if(playState) {
						change = "red";
						gain = 0.25;
					} else {
						change = "white";
						gain = 0;
					}
					
					vca.gain.value = gain;
				}
			});
		</script>
		<style>
			.wholePageDiv {
				height: 100%; 
			}
			
			.selectDiv {
				height: 10%;
			}
			
			.outputarea {
				height: 80%;
			}
			
			#controlDiv {
				height: 10%;
			}
			
			textarea {
				width: 100%;
				height: 45%;
			}
			
			#progbar {
				background-color: black;
				width: 0;
			}
		</style>
	</head>
	<body>
		<div class="wholePageDiv">
			<div class="selectDiv">
				<select id="controlselect">
					<option>Select a tool</option>
					<option value="texttrans">Text Translator</option>
					<option value="transmitwindow">Transmit Window</option>
				</select>
			</div>
			<div class="outputarea" id="texttrans">
				URL (Only works with static HTML or TXT pages, very beta): <input type="text" id="url2load"/> <input type="button" id="geturl" value="Get"/><br/><br/>
				<textarea id="plaintext" class="top"></textarea><br/>
				<textarea id="morsetext" class="bottom"></textarea><br/>
			</div>
			<div class="outputarea" id="transmitwindow">
				Input Type: <select id="inputtype">
								<option value="straight" selected>Straight-Key</option>
								<!--option value="paddle">Paddles(Nonfunctional)</option-->
							</select><br/>
				<textarea id="transmitarea"></textarea>
			</div>
			<div id="controlDiv">
				<input type="button" id="clearButton" value="Clear">
				Sound Frequency: <input type="text" id="soundfreq" value="700">
				<input type="button" id="playButton" value="Play">
				WPM: <input type="text" id="wpmbox" value="25"/>
			</div>
		</div
	</body>
</html>