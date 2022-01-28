module BetterMath {

	function min(number1, number2) {
		return number1 < number2 ? number1 : number2;
	}

	function max(number1, number2) {
		return number1 < number2 ? number2 : number1;
	}

	function mean(number1, number2) {
		return weightedMean(number1, number2, 0.5);
	}

	function weightedMean(number1, number2, weight_ratio) {
		return (number1 - number2).abs() * weight_ratio + min(number1, number2);
	}
}
