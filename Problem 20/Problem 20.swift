import Foundation

extension StringProtocol {
	var nsrange: NSRange {
		return NSRange(location: 0, length: self.utf16.count)
	}
}

class Coordinate: Equatable, Hashable, CustomStringConvertible {
	static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
		return lhs.east == rhs.east && lhs.south == rhs.south
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(east)
		hasher.combine(south)
	}
	
	public var description: String {
		return "(\(east), \(south))"
	}
	
	var east: Int
	var south: Int
	
	init(_ east: Int, _ south: Int) {
		self.east = east
		self.south = south
	}
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
	private var hasBeenShrunk = false
	
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
	
	func findSeaMonster() -> Int {
		var monsterCount = 0
		let line1Regex = try! NSRegularExpression(pattern: #"..................#."#, options: [])
		let line2Regex = try! NSRegularExpression(pattern: #"#....##....##....###"#, options: [])
		let line3Regex = try! NSRegularExpression(pattern: #".#..#..#..#..#..#..."#, options: [])
		outerLoop: for tile in self.permutations() {
			var count = 0
			for i in 0..<tile.size - 2 {
				// Go through each line and see if the line matches the first regex
				let line = tile.data[i].joined(separator: "")
				let line2 = tile.data[i + 1].joined(separator: "")
				let line3 = tile.data[i + 2].joined(separator: "")
				let matches1 = line1Regex.matches(in: line, options: [], range: line.nsrange)
				if matches1.count > 0 {
					// We have a match on line 1, go to the next line
					let matches2 = line2Regex.matches(in: line2, options: [], range: line2.nsrange)
					if matches2.count > 0 {
						// We have a match on line2, let's check line 3
						let matches3 = line3Regex.matches(in: line3, options: [], range: line3.nsrange)
						if matches3.count > 0 {
							// We have some seamonsters!
							count += min(min(matches1.count, matches2.count), matches3.count)
						}
					}
				}
			}
			monsterCount = max(monsterCount, count)
		}
		return monsterCount
	}
	
	func findHardness() -> Int {
		let monsterCount = self.findSeaMonster()
		let allHardSquares = self.data.map { $0.filter { $0 == "#" }.count }.reduce(0, +)
		// Each sea monster has 15 #'s in it
		return allHardSquares - monsterCount * 15
	}
	
	func shrink() {
		if !hasBeenShrunk {
			self.data = Array(self.data.map({ Array($0[1...$0.count - 2]) })[1...self.data.count - 2])
			self.size = self.data[0].count
			self.hasBeenShrunk = true
		}
	}
	
	func placeTile(_ other: Tile) -> Bool {
		if self.eastTile != nil && self.eastTile!.placeTile(other) {
			return true
		}
		else if self.westTile != nil && self.westTile!.placeTile(other) {
			return true
		}
		else if self.southTile != nil && self.southTile!.placeTile(other) {
			return true
		}
		else if self.northTile != nil && self.northTile!.placeTile(other) {
			return true
		}
		// no other tiles - see if we can place it here
		for tile in other.permutations() {
			if self.northTile == nil && self.matchesNorth(tile) {
				self.northTile = tile
				return true
			}
			if self.eastTile == nil && self.matchesEast(tile) {
				self.eastTile = tile
				return true
			}
			if self.southTile == nil && self.matchesSouth(tile) {
				self.southTile = tile
				return true
			}
			if self.westTile == nil && self.matchesWest(tile) {
				self.westTile = tile
				return true
			}
		}
		// Didn't match, return false
		return false
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
		var desc = "Tile ID \(id) (size \(size)):\n"
		desc += data.map { "\($0.joined(separator: ""))\n" }.joined()
		return desc
	}
}

func buildMap(_ corners: [Tile], _ edges: [Tile], _ allTiles: [Tile]) -> Tile {
	var availableTiles = Set(allTiles).subtracting(corners).subtracting(edges)
	let startingCorner = corners[0]
	var borderTilesList = corners
	borderTilesList.append(contentsOf: edges)
	var borderTiles = Set(borderTilesList)
	borderTiles.remove(startingCorner)
	let mapSize = Int(sqrt(Double(allTiles.count)))
	
	// Start at one corner and place all the edge tiles
	while borderTiles.count > 0 {
		for tile in borderTiles {
			if startingCorner.placeTile(tile) {
				borderTiles.remove(tile)
			}
		}
	}
	// Now fill in the rest of the tiles
	while availableTiles.count > 0 {
		for tile in availableTiles {
			if startingCorner.placeTile(tile) {
				availableTiles.remove(tile)
			}
		}
	}
	
	var map = [Coordinate: Tile]()
	
	// Now build the map from the linked list
	map[Coordinate(0, 0)] = startingCorner
	var currentTile: Tile? = nil
	if startingCorner.eastTile != nil {
		currentTile = startingCorner.eastTile
		for i in 1..<mapSize {
			map[Coordinate(i, 0)] = currentTile!
			currentTile = currentTile!.eastTile
		}
	} else if startingCorner.westTile != nil {
		currentTile = startingCorner.westTile
		for i in 1..<mapSize {
			map[Coordinate(-i, 0)] = currentTile!
			currentTile = currentTile!.westTile
		}
	}
	if startingCorner.southTile != nil {
		currentTile = startingCorner.southTile
		for i in 1..<mapSize {
			map[Coordinate(0, i)] = currentTile!
			currentTile = currentTile!.southTile
		}
	} else if startingCorner.northTile != nil {
		currentTile = startingCorner.northTile
		for i in 1..<mapSize {
			map[Coordinate(0, -i)] = currentTile!
			currentTile = currentTile!.northTile
		}
	}
	while map.count != allTiles.count {
		for t in map {
			let coord = t.key
			let tile = t.value
			if tile.northTile != nil {
				map[Coordinate(coord.east, coord.south - 1)] = tile.northTile!
			}
			if tile.southTile != nil {
				map[Coordinate(coord.east, coord.south + 1)] = tile.southTile!
			}
			if tile.eastTile != nil {
				map[Coordinate(coord.east + 1, coord.south)] = tile.eastTile!
			}
			if tile.westTile != nil {
				map[Coordinate(coord.east - 1, coord.south)] = tile.westTile!
			}
		}
	}
	// Now build the tile
	var tileData = "Tile 0:\n"
	startingCorner.shrink()
	for south in -mapSize...mapSize {
		var line: [String] = Array(repeating: "", count: startingCorner.size)
		for east in -mapSize...mapSize {
			let tile = map[Coordinate(east, south)]
			if tile != nil {
				tile!.shrink()
				for i in 0..<tile!.data[0].count {
					line[i] += tile!.data[i].joined(separator: "")
				}
			}
		}
		if line.filter({ $0.count > 0 }).count > 0 {
			tileData += line.joined(separator: "\n")
			tileData += "\n"
		}
	}
	return Tile(tileData)
}


let problemFile = String(try NSString(contentsOfFile: "./input.txt", encoding: String.Encoding.ascii.rawValue))
let tiles = problemFile.components(separatedBy: "\n\n").map { Tile($0) }
let corners = tiles.filter { $0.isCorner(tiles) }
let edges = tiles.filter { $0.isEdge(tiles) }

let testFile = String(try NSString(contentsOfFile: "./testfile.txt", encoding: String.Encoding.ascii.rawValue))
let testTiles = testFile.components(separatedBy: "\n\n").map { Tile($0) }
let testCorners = testTiles.filter { $0.isCorner(testTiles) }
let testEdges = testTiles.filter { $0.isEdge(testTiles) }

print("In test file, \(testCorners.map { $0.id }) are corners. Their product is \(testCorners.map { $0.id }.reduce(1, *)) (should be 20899048083289).")
print("In real file, \(corners.map { $0.id }) are corners. Their product is \(corners.map { $0.id }.reduce(1, *)).")

let testMap = buildMap(testCorners, testEdges, testTiles)
print("Full test map:")
print(testMap)
print("There are \(testMap.findSeaMonster()) sea monsters in the test map (should be 2).")
print("Test map has a hardness of \(testMap.findHardness()) (should be 273).")

let map = buildMap(corners, edges, tiles)
print("Full real map:")
print(map)
print("There are \(map.findSeaMonster()) sea monsters in the real map.")
print("Real map has a hardness of \(map.findHardness()).")