using Toybox.Time as Time;

module HelpersTest {

	(:test)
	function testFormatString(logger) {
		var string = "${name} is the ${family-relation} of ${other_name}";
		var replacements = {"name" => "Luke", "family-relation" => "son", "other_name" => "Anakin"};
		BetterTest.assertEqual(Helpers.formatString(string, replacements), "Luke is the son of Anakin", "Format string function fill a special string with data from a dictionary");
		replacements = {"other_name" => "Luke", "name" => "Anakin", "family-relation" => "father"};
		BetterTest.assertEqual(Helpers.formatString(string, replacements), "Anakin is the father of Luke", "Format string function works with parameters in any order");

		string = "${name} has ${children_number} children: he is the father of ${other_name} and ${other_name} is the brother of ${third_name}";
		replacements = {"third_name" => "Leia", "other_name" => "Luke", "name" => "Anakin", "children_number" => 2};
		BetterTest.assertEqual(Helpers.formatString(string, replacements), "Anakin has 2 children: he is the father of Luke and Luke is the brother of Leia", "Format string function works with numbers and is able to use same parameter twice");
		return true;
	}

	(:test)
	function testFormatDuration(logger) {
		var duration = 2 * 3600 + 28 * 60 + 42;
		BetterTest.assertEqual(Helpers.formatDuration(new Time.Duration(duration)), "02:28:42", "Formatting a duration gives the good string");

		duration = 355 * 3600 + 2 * 60 + 4;
		BetterTest.assertEqual(Helpers.formatDuration(new Time.Duration(duration)), "355:02:04", "Formatting a duration gives the good string");
		return true;
	}
}
