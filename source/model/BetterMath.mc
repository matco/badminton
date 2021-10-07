import Toybox.Lang;

module BetterMath {

	function min(number1 as Float, number2 as Float) as Float {
		return number1 < number2 ? number1 : number2;
	}

	function max(number1 as Float, number2 as Float) as Float {
		return number1 < number2 ? number2 : number1;
	}

	function mean(number1 as Float, number2 as Float) as Float {
		return weightedMean(number1, number2, 0.5);
	}

	function weightedMean(number1 as Float, number2 as Float, weight_ratio as Float) as Float {
		return (number1 - number2).abs() * weight_ratio + min(number1, number2);
	}
}
