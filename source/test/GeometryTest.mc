using Toybox.Time as Time;

module GeometryTest {

	(:test)
	function testChordLength(logger) {
		BetterTest.assertEqual(Geometry.chordLength(5, 1), 6f, "Chord length at distance 1 in a circle with radius equals to 5 is 6");
		return true;
	}

}