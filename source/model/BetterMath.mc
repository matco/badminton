import Toybox.Lang;
import Toybox.Math;

module BetterMath {

	function min(number1 as Numeric, number2 as Numeric) as Numeric {
		return number1 < number2 ? number1 : number2;
	}

	function max(number1 as Numeric, number2 as Numeric) as Numeric {
		return number1 < number2 ? number2 : number1;
	}

	function mean(number1 as Numeric, number2 as Numeric) as Numeric {
		return weightedMean(number1, number2, 0.5);
	}

	function weightedMean(number1 as Numeric, number2 as Numeric, weight_ratio as Numeric) as Numeric {
		return (number1 - number2).abs() * weight_ratio + min(number1, number2);
	}

	function roundAll(numbers as Array<Numeric>) as Array<Numeric> {
		var rounded = new [numbers.size()] as Array<Numeric>;
		for(var i = 0; i < numbers.size(); i++) {
			rounded[i] = Math.round(numbers[i]);
		}
		return rounded;
	}
}
