import Foundation

extension String {
    func groups(for regexPattern: String) -> [[String]] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

class MovementVector {
    var direction: Int?
    var rotation: Int?
    var amount: Int?
    
    init(movement: String) {
        let stringComponents = movement.groups(for: #"([A-Z])(\d+)"#)[0]
        switch stringComponents[1] {
        case "N":
            direction = 0
            amount = Int(stringComponents[2])!
            break
        case "E":
            direction = 90
            amount = Int(stringComponents[2])!
            break
        case "S":
            direction = 180
            amount = Int(stringComponents[2])!
            break
        case "W":
            direction = 270
            amount = Int(stringComponents[2])!
            break
        case "L":
            rotation = -Int(stringComponents[2])!
            break
        case "R":
            rotation = Int(stringComponents[2])!
            break
        case "F":
            amount = Int(stringComponents[2])!
            break
        default:
            print("Got unexpected direction \(stringComponents[1])")
            break
        }
    }
}

class PositionVector {
    var heading: Int
    var xPosition: Int
    var yPosition: Int
    var startXPosition: Int
    var startYPosition: Int
    
    init(initialHeading: Int, initialX: Int, initialY: Int) {
        heading = initialHeading
        xPosition = initialX
        yPosition = initialY
        startXPosition = initialX
        startYPosition = initialY
    }
    
    func manhattanDistanceFromStart() -> Int {
        return abs(xPosition) + abs(yPosition)
    }
    
    func move(movement: MovementVector) {
        // If we need to turn, change the rotation
        if movement.rotation != nil {
            heading += movement.rotation!
            if heading < 0 {
                heading = 360 + heading
            } else if heading >= 360 {
                heading = heading - 360
            }
        }
        // If we just need to move in this direction, move with the current heading
        if movement.direction == nil && movement.amount != nil {
            move(movementAmount: movement.amount!)
        }
        // If we need to move in a different direction, move with a specific heading
        if movement.direction != nil {
            move(movementAmount: movement.amount!, movementHeading: movement.direction!)
        }
    }
    
    private func move(movementAmount: Int, movementHeading: Int? = nil) {
        let moveHeading = movementHeading == nil ? heading : movementHeading!
        switch moveHeading {
        case 0:
            xPosition += movementAmount
            break
        case 90:
            yPosition += movementAmount
            break
        case 180:
            xPosition -= movementAmount
            break
        case 270:
            yPosition -= movementAmount
            break
        default:
            print("Unexpected heading \(moveHeading)")
            break
        }
    }
}

class PositionVectorWithWaypoint {
    var xPosition: Int
    var yPosition: Int
    var waypointXOffset: Int
    var waypointYOffset: Int
    var startXPosition: Int
    var startYPosition: Int
    
    init(initialX: Int, initialY: Int, initialWaypointX: Int, initialWaypointY: Int) {
        xPosition = initialX
        yPosition = initialY
        startXPosition = initialX
        startYPosition = initialY
        waypointXOffset = initialWaypointX
        waypointYOffset = initialWaypointY
    }
    
    func manhattanDistanceFromStart() -> Int {
        return abs(xPosition) + abs(yPosition)
    }
    
    func move(movement: MovementVector) {
        // We need to rotate the waypoint around the ship
        if movement.rotation != nil {
            let originalX = waypointXOffset
            let originalY = waypointYOffset
            switch movement.rotation {
            // Clockwise 90º
            case 90, -270:
                waypointXOffset = -originalY
                waypointYOffset = originalX
                break
            // CCW 90º
            case -90, 270:
                waypointXOffset = originalY
                waypointYOffset = -originalX
                break
            // 180º
            case 180, -180:
                waypointXOffset = -originalX
                waypointYOffset = -originalY
                break
            default:
                print("Unexpected waypoint rotation \(movement.rotation!)")
                break
            }
        }
        // Move to the waypoint N times
        if movement.direction == nil && movement.amount != nil {
            xPosition += waypointXOffset * movement.amount!
            yPosition += waypointYOffset * movement.amount!
        }
        // Move the waypoint relative to the ship in a specific direction
        if movement.direction != nil {
            moveWaypoint(movementAmount: movement.amount!, moveHeading: movement.direction!)
        }
    }
    
    private func moveWaypoint(movementAmount: Int, moveHeading: Int) {
        switch moveHeading {
        case 0:
            waypointXOffset += movementAmount
            break
        case 90:
            waypointYOffset += movementAmount
            break
        case 180:
            waypointXOffset -= movementAmount
            break
        case 270:
            waypointYOffset -= movementAmount
            break
        default:
            print("Unexpected heading \(moveHeading)")
            break
        }
    }
}

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)
//let problemFile = """
//F10
//N3
//F7
//R90
//F11
//"""

let directions = problemFile.components(separatedBy: "\n")
    .filter { $0.count > 0}.map { MovementVector(movement: $0) }
let position = PositionVector(initialHeading: 90, initialX: 0, initialY: 0)
directions.map { position.move(movement: $0) }
print("With no waypoints, the ship ended \(position.manhattanDistanceFromStart()) units from the start position.")

let positionWithWaypoint = PositionVectorWithWaypoint(initialX: 0, initialY: 0, initialWaypointX: 1, initialWaypointY: 10)
directions.map { positionWithWaypoint.move(movement: $0) }
print("Using waypoints, the ship ended \(positionWithWaypoint.manhattanDistanceFromStart()) units from the start position.")
