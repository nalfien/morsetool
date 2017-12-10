<?php
	$output = "";
	$url = $_POST["url"];
	
	function procHtml($toProc) {
		$procArray = explode("\n", $toProc);
		
		$outHTML = "";
		
		$i = 0;
		
		for(; $i < count($procArray) && strpos($procArray[$i], "<body") === false; $i++);
		
		$gtlev = 0;
		
		for(; $i < count($procArray) && strpos($procArray[$i], "</body") === false; ($outHTML .= "\n") && $i++) {
			foreach(str_split($procArray[$i]) as $let) {
				if($let == "<") {
					$gtlev++;
				} else if($let == ">") {
					$gtlev--;
				} else if($gtlev == 0) {
					if($let != '\n') {
						$outHTML .= $let;
					}
				}
			}
		}
		
		return $outHTML;
	}
	
	$input = file_get_contents($url);
	
	switch(substr($url, strrpos($url, "."))) {
		case ".txt":
			$output = $input;
			break;
		default:
			$output = procHtml($input);
			break;
	}
	
	echo $output;
?>