import Foundation

extension StringProtocol {
	subscript(_ range: NSRange) -> SubSequence { prefix(range.lowerBound+range.length).suffix(range.length) }
	var nsrange: NSRange {
		return NSRange(location: 0, length: self.utf16.count)
	}
}

func +(left: HexCoordinate, right: HexCoordinate) -> HexCoordinate {
	return HexCoordinate(left.x + right.x, left.y + right.y, left.z + right.z)
}

class HexCoordinate: CustomStringConvertible, Equatable, Hashable {
	static func == (lhs: HexCoordinate, rhs: HexCoordinate) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(x)
		hasher.combine(y)
		hasher.combine(z)
	}
	
	var x: Int = 0
	var y: Int = 0
	var z: Int = 0
	
	init(_ x: Int, _ y: Int, _ z: Int) {
		self.x = x
		self.y = y
		self.z = z
	}
	
	init(_ directionString: String) {
		let regex = try! NSRegularExpression(pattern: #"(se)|(ne)|(nw)|(sw)|(w)|(e)"#, options: [])
		let matches = regex.matches(in: directionString, options: [], range: directionString.nsrange)
		for match in matches {
			let direction = directionString[match.range]
			switch direction {
				case "nw":
					y += 1
					z -= 1
					break
				case "se":
					y -= 1
					z += 1
					break
				case "ne":
					x += 1
					z -= 1
					break
				case "sw":
					x -= 1
					z += 1
				case "e":
					x += 1
					y -= 1
					break
				case "w":
					x -= 1
					y += 1
					break
				default:
					print("should never get here...")
					break
			}
		}
	}
	
	func neighbors() -> [HexCoordinate] {
		return [HexCoordinate(x, y + 1, z - 1),
				HexCoordinate(x, y - 1, z + 1),
				HexCoordinate(x + 1, y, z - 1),
				HexCoordinate(x - 1, y, z + 1), 
				HexCoordinate(x + 1, y - 1, z),
				HexCoordinate(x - 1, y + 1, z)]
	}
	
	var description: String {
		return "(\(x), \(y), \(z))"
	}
}

func solvePart1(_ coordinates: [HexCoordinate]) {
	let dict = Dictionary(grouping: coordinates, by: { $0 })
	let duplicates = dict.filter { $1.count > 1 }.keys
	print("There are \(duplicates.count) tiles that were flipped more than once.")
	print("\(coordinates.filter { !duplicates.contains($0) }.count) tiles are left black.")
}

func solvePart2(_ coordinates: [HexCoordinate]) {
	// Keep track of which tiles are black (true)
	var coordinateSpace = Dictionary<HexCoordinate, Bool>()
	for coordinate in coordinates {
		if coordinateSpace[coordinate] == nil {
			coordinateSpace[coordinate] = true
		} else {
			coordinateSpace[coordinate] = !coordinateSpace[coordinate]!
		}
	}
	for _ in 1...100 {
		// first thing to do is expand the space by 1
		let newTiles = coordinateSpace.keys.flatMap { $0.neighbors() }.filter { !coordinateSpace.keys.contains($0) }
		for tile in newTiles {
			coordinateSpace[tile] = false
		}
		// Now make a copy of the space to work off
		let tmpSpace = coordinateSpace
		for coordinate in coordinateSpace.keys {
			let neighborCount = coordinate.neighbors().map { tmpSpace[$0] ?? false }.filter { $0 }.count
			// Any black tile with zero or more than 2 black tiles immediately adjacent to it is flipped to white
			if tmpSpace[coordinate]! && neighborCount == 0 || neighborCount > 2 {
				coordinateSpace[coordinate] = false
			} 
			// Any white tile with exactly 2 black tiles immediately adjacent to it is flipped to black
			else if !tmpSpace[coordinate]! && neighborCount == 2 {
				coordinateSpace[coordinate] = true
			}
		}
	}
	print("After 100 days, there are \(coordinateSpace.values.filter { $0 }.count) black tiles facing up.")
}


let testFile = """
sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew
"""

print("--- Test File ---")
var testCoordinates = testFile.components(separatedBy: .newlines).map { HexCoordinate($0) }
solvePart1(testCoordinates)
solvePart2(testCoordinates)

print("\n--- Real File ---")
let problemFile = String(try NSString(contentsOfFile: "./input.txt", encoding: String.Encoding.ascii.rawValue))
let coordinates = problemFile.components(separatedBy: "\n").map { HexCoordinate($0) }
solvePart1(coordinates)
solvePart2(coordinates)