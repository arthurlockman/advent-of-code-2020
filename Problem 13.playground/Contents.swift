import Foundation

class Bus: Equatable {
    
    static func == (lhs: Bus, rhs: Bus) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var index: Int
    
    init(id: String, index: Int) {
        if (id == "x") {
            self.id = -1
        } else {
            self.id = Int(id)!
        }
        self.index = index
    }
    
    func GetNearestDeparture(timeCode: Int) -> Int {
        if (id == -1) {
            return Int.max
        }
        let difference = timeCode % id
        return difference == 0 ? timeCode : timeCode + id - difference
    }
    
    func ValidateDepartureOrder(timeCode: Int) -> Bool {
        return id == -1 || (timeCode + index) % id == 0
    }
}

let problemFile = """
1000511
29,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,37,x,x,x,x,x,409,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,17,13,19,x,x,x,23,x,x,x,x,x,x,x,353,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41
""".components(separatedBy: "\n")

let currentTime = Int(problemFile[0])!
var buses = problemFile[1].components(separatedBy: ",").enumerated().map { Bus(id: $1, index: $0) }

let earliestBus = buses.min { $0.GetNearestDeparture(timeCode: currentTime) < $1.GetNearestDeparture(timeCode: currentTime) }
let waitTime = earliestBus!.GetNearestDeparture(timeCode: currentTime) - currentTime

print("The earliest bus is bus \(earliestBus!.id), and you'll have to wait \(waitTime) minutes for it to come (product is \(earliestBus!.id * waitTime)).\n")

var conditionMet = false

var largestBus = buses.max { $0.id < $1.id }!
var largestBusIndex = buses.firstIndex(of: largestBus)!

var timeStamp = largestBus.id - largestBusIndex
var step = largestBus.id
print("Largest bus is \(largestBus.id) at index \(largestBusIndex)")
print("Starting at timestamp \(timeStamp), step size \(step)\n")

buses.remove(at: buses.firstIndex(of: largestBus)!)

while (true) {
    for bus in buses {
        if bus.ValidateDepartureOrder(timeCode: timeStamp) {
            if (bus.id >= 0) {
                step *= bus.id
                print("Bus \(bus.id) at position \(bus.index) satisfied at \(timeStamp)")
            }
            buses.remove(at: buses.firstIndex(of: bus)!)
        }
    }
    if buses.isEmpty {
        break
    }
    timeStamp += step
}

print("Earliest alignment timestamp is \(timeStamp).")
