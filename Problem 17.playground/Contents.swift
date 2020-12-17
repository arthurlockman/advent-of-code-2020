import Foundation

class Coordinate: CustomStringConvertible, Equatable, Hashable {
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
    
    var description: String { return "(\(x), \(y), \(z))"}
    
    var x: Int
    var y: Int
    var z: Int
    
    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func neighbors() -> [Coordinate] {
        var neighbors: [Coordinate] = []
        for x in self.x - 1...self.x + 1 {
            for y in self.y - 1...self.y + 1 {
                for z in self.z - 1...self.z + 1 {
                    let newCoord = Coordinate(x: x, y: y, z: z)
                    if (newCoord != self) {
                        neighbors.append(newCoord)
                    }
                }
            }
        }
        return neighbors
    }
}

class Coordinate4D: CustomStringConvertible, Equatable, Hashable {
    static func == (lhs: Coordinate4D, rhs: Coordinate4D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
        hasher.combine(w)
    }
    
    var description: String { return "(\(x), \(y), \(z), \(w)"}
    
    var x: Int
    var y: Int
    var z: Int
    var w: Int
    
    init(x: Int, y: Int, z: Int, w: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    func neighbors() -> [Coordinate4D] {
        var neighbors: [Coordinate4D] = []
        for x in self.x - 1...self.x + 1 {
            for y in self.y - 1...self.y + 1 {
                for z in self.z - 1...self.z + 1 {
                    for w in self.w - 1...self.w + 1 {
                        let newCoord = Coordinate4D(x: x, y: y, z: z, w: w)
                        if (newCoord != self) {
                            neighbors.append(newCoord)
                        }
                    }
                }
            }
        }
        return neighbors
    }
}

func runCycle(initialSpace: Dictionary<Coordinate, Bool>) -> Dictionary<Coordinate, Bool> {
    var newSpace = Dictionary<Coordinate, Bool>()
    let allPoints = Set(initialSpace.keys.flatMap({ $0.neighbors() }))
    for point in allPoints {
        let cube = initialSpace[point]
        var activeCount = 0
        for neighborPoint in point.neighbors() {
            let neighbor = initialSpace[neighborPoint]
            if neighbor != nil && neighbor! {
                activeCount += 1
            }
        }
        let nonNullCube = cube == nil ? false : cube!
        if nonNullCube && (activeCount == 2 || activeCount == 3) {
            newSpace[point] = true
        } else if nonNullCube {
            newSpace[point] = false
        } else if !nonNullCube && activeCount == 3 {
            newSpace[point] = true
        } else {
            newSpace[point] = false
        }
    }
    return newSpace
}

func runCycle4D(initialSpace: Dictionary<Coordinate4D, Bool>) -> Dictionary<Coordinate4D, Bool> {
    var newSpace = Dictionary<Coordinate4D, Bool>()
    let allPoints = Set(initialSpace.keys.flatMap({ $0.neighbors() }))
    for point in allPoints {
        let cube = initialSpace[point]
        var activeCount = 0
        for neighborPoint in point.neighbors() {
            let neighbor = initialSpace[neighborPoint]
            if neighbor != nil && neighbor! {
                activeCount += 1
            }
        }
        let nonNullCube = cube == nil ? false : cube!
        if nonNullCube && (activeCount == 2 || activeCount == 3) {
            newSpace[point] = true
        } else if nonNullCube {
            newSpace[point] = false
        } else if !nonNullCube && activeCount == 3 {
            newSpace[point] = true
        } else {
            newSpace[point] = false
        }
    }
    return newSpace
}

let initialState =
"""
#####..#
#..###.#
###.....
.#.#.#..
##.#..#.
######..
.##..###
###.####
"""

// dictionary of x, y, z
var space = Dictionary<Coordinate, Bool>()
var space4D = Dictionary<Coordinate4D, Bool>()

for line in initialState.components(separatedBy: "\n").enumerated() {
    for cube in Array(line.element).enumerated() {
        let x = line.offset
        let y = cube.offset
        let active = cube.element == "#"
        space[Coordinate(x: x, y: y, z: 0)] = active
        space4D[Coordinate4D(x: x, y: y, z: 0, w: 0)] = active
    }
}

for _ in 1...6 {
    space = runCycle(initialSpace: space)
}

print("In 3D space, \(space.values.filter { $0 }.count) cubes are active after 6 cycles.")

for _ in 1...6 {
    space4D = runCycle4D(initialSpace: space4D)
}

print("In 4D space, \(space4D.values.filter { $0 }.count) cubes are active after 6 cycles.")
