module GeometryTest {

	(:test)
	function testChordLength(logger) {
		BetterTest.assertEqual(Geometry.chordLength(5f, 4f), 6f, "In a circle with a radius of 5, the chord length at the distance of 4 from the center of the circle is 6");
		return true;
	}
}
