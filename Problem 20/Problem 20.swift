import Foundation

enum Direction {
	case North
	case South
	case West
	case East
}

class Tile: CustomStringConvertible, Equatable, Hashable {
	static func == (lhs: Tile, rhs: Tile) -> Bool {
		return lhs.id == rhs.id && lhs.size == rhs.size
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(size)
	}
	
	var data: [[String]]
	var id: Int
	var size: Int
	
	// Map references
	var northTile: Tile?
	var southTile: Tile?
	var eastTile: Tile?
	var westTile: Tile?
	
	init(_ tileData: String) {
		let split = tileData.components(separatedBy: .newlines)
		id = Int(split[0].replacingOccurrences(of: "Tile ", with: "").replacingOccurrences(of: ":", with: ""))!
		data = split[1...split.count - 1].compactMap { Array($0).map { String($0) } }
		size = data[0].count
	}
	
	init(data: [[String]], id: Int) {
		self.data = data
		self.id = id
		self.size = data[0].count
	}
	
	func rotate90() -> Tile {
		var newTile = [[String]](repeating: [String](repeating: "", count: size), count: size)
		for i in 0..<size {
			for j in 0..<size {
				newTile[i][j] = data[size - j - 1][i]
			}
		}
		return Tile(data: newTile, id: self.id)
	}
	
	func flipHoriz() -> Tile {
		var newTile = [[String]](repeating: [String](repeating: "", count: size), count: size)
		for i in 0..<size {
			for j in 0..<size {
				newTile[size - 1 - i][j] = data[i][j]
			}
		}
		return Tile(data: newTile, id: self.id)
	}
	
	func flipVert() -> Tile {
		var newTile = [[String]](repeating: [String](repeating: "", count: size), count: size)
		for i in 0..<size {
			for j in 0..<size {
				newTile[i][size - 1 - j] = data[i][j]
			}
		}
		return Tile(data: newTile, id: self.id)
	}
	
	func permutations() -> [Tile] {
		let tmp1 = self.rotate90() // 90º
		let tmp2 = tmp1.rotate90() // 180º
		let tmp3 = tmp2.rotate90() // 270˚
		let tmp4 = self.flipHoriz()
		let tmp5 = tmp4.rotate90()
		let tmp6 = tmp5.rotate90()
		let tmp7 = tmp6.rotate90()
		let tmp8 = self.flipVert()
		let tmp9 = tmp8.rotate90()
		let tmp10 = tmp9.rotate90()
		let tmp11 = tmp10.rotate90()
		return [self, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9, tmp10, tmp11] // 0º, 90º, 180º, 270º rotated
	}
	
	func isCorner(_ allTiles: [Tile]) -> Bool {
		return self.countMatchedEdges(allTiles) == 2
	}
	
	func isEdge(_ allTiles: [Tile]) -> Bool {
		return self.countMatchedEdges(allTiles) == 3
	}
	
	private func countMatchedEdges(_ allTiles: [Tile]) -> Int {
		var matchedEdges = [false, false, false, false]
		let allPermutations = allTiles.filter({ $0 != self }).flatMap({ $0.permutations() })
		for otherTile in allPermutations {
			matchedEdges[0] = matchedEdges[0] || self.matchesNorth(otherTile)
			matchedEdges[1] = matchedEdges[1] || self.matchesSouth(otherTile)
			matchedEdges[2] = matchedEdges[2] || self.matchesEast(otherTile)
			matchedEdges[3] = matchedEdges[3] || self.matchesWest(otherTile)
		}
		return matchedEdges.filter { $0 }.count
	}
	
	func matchesNorth(_ other: Tile) -> Bool {
		if other == self {
			return false
		}
		for i in 0..<size {
			if data[0][i] != other.data[size - 1][i] {
				return false
			}
		}
		return true
	}
	
	func matchesSouth(_ other: Tile) -> Bool {
		if other == self {
			return false
		}
		for i in 0..<size {
			if data[size - 1][i] != other.data[0][i] {
				return false
			}
		}
		return true
	}
	
	func matchesEast(_ other: Tile) -> Bool {
		if other == self {
			return false
		}
		for i in 0..<size {
			if data[i][size - 1] != other.data[i][0] {
				return false
			}
		}
		return true
	}
	
	func matchesWest(_ other: Tile) -> Bool {
		if other == self {
			return false
		}
		for i in 0..<size {
			if data[i][0] != other.data[i][size - 1] {
				return false
			}
		}
		return true
	}
	
	public var description: String {
		var desc = "Tile ID \(id):\n"
		desc += data.map { "\($0.joined(separator: ""))\n" }.joined()
		return desc
	}
}


let problemFile = String(try NSString(contentsOfFile: "./input.txt", encoding: String.Encoding.ascii.rawValue))
let tiles = problemFile.components(separatedBy: "\n\n").map { Tile($0) }
let corners = tiles.filter { $0.isCorner(tiles) }.map { $0.id }
let edges = tiles.filter { $0.isEdge(tiles) }

let testFile = String(try NSString(contentsOfFile: "./testfile.txt", encoding: String.Encoding.ascii.rawValue))
let testTiles = testFile.components(separatedBy: "\n\n").map { Tile($0) }
let testCorners = testTiles.filter { $0.isCorner(testTiles) }.map { $0.id }
let testEdges = testTiles.filter { $0.isEdge(testTiles) }

print("In test file, \(testCorners) are corners. Their product is \(testCorners.reduce(1, *)) (should be 20899048083289).")
print("In real file, \(corners) are corners. Their product is \(corners.reduce(1, *)).")
