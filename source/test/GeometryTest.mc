using Toybox.Time as Time;

module GeometryTest {

	function testChordLength() {
		Assert.isEqual(Geometry.chordLength(5, 1), 6f, "Chord length at distance 1 in a circle with radius equals to 5 is 6");
	}

}