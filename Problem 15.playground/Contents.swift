import Foundation

func runMemoryGame(input: String, iterations: Int) -> Int {
    // Keep track of the last time a number was spoken and what turn numbers that was
    var numberMemory = Dictionary<Int, [Int]>()
    let startingNumbers = input.components(separatedBy: ",").map { Int($0)! }
    var lastNumberSpoken: Int? = nil
    for turn in 0...iterations - 1 {
        if turn < startingNumbers.count {
            numberMemory[startingNumbers[turn]] = [turn]
            lastNumberSpoken = startingNumbers[turn]
        } else {
            let memory = numberMemory[lastNumberSpoken!]
            if memory != nil && (memory!.last != turn - 1 || (memory!.last == turn - 1 && memory!.count > 1)) {
                lastNumberSpoken = memory!.last! - memory![memory!.count - 2]
            } else {
                lastNumberSpoken = 0
            }
            var newMemory = numberMemory[lastNumberSpoken!]
            if (newMemory == nil) {
                newMemory = [turn]
            } else {
                newMemory!.append(turn)
            }
            numberMemory[lastNumberSpoken!] = newMemory!.suffix(2)
        }
    }
    return lastNumberSpoken!
}

let testCases = [
    ("0,3,6", 436),
    ("1,3,2", 1),
    ("2,1,3", 10),
    ("1,2,3", 27),
    ("2,3,1", 78),
    ("3,2,1", 438),
    ("3,1,2", 1836)
]
let iterations = 2020

let puzzleInput = "0,5,4,1,10,14,7"

for testCase in testCases {
    let result = runMemoryGame(input: testCase.0, iterations: iterations)
    if result == testCase.1 {
        print("Test case \(testCase.0) passed.")
    } else {
        print("Test case \(testCase.0) failed. Result was \(result), should be \(testCase.1).")
    }
}

print("Puzzle output for iteration 2020 is \(runMemoryGame(input: puzzleInput, iterations: iterations))")

print("Here we go...")
print("Puzzle output for iteration 30000000 is \(runMemoryGame(input: puzzleInput, iterations: 30000000))")
