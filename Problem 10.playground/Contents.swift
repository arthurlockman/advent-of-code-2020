import Foundation

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

let joltageAdapters = problemFile.components(separatedBy: "\n")
    .filter({ $0.count > 0 }).map({ Int($0)! })

var wallJoltage = 0
var deviceJoltage = joltageAdapters.max()! + 3

var sortedJoltages = [0]
sortedJoltages.append(contentsOf: joltageAdapters.sorted())
sortedJoltages.append(deviceJoltage)
var oneJoltDifferences = 0
var threeJoltDifferences = 0
for i in 1...sortedJoltages.count - 1 {
    let difference = sortedJoltages[i] - sortedJoltages[i - 1]
    if (difference == 3) {
        threeJoltDifferences += 1
    } else if (difference == 1) {
        oneJoltDifferences += 1
    }
}
print("Three jolt differences: \(threeJoltDifferences)")
print("One jolt differences: \(oneJoltDifferences)")
print("Product: \(oneJoltDifferences * threeJoltDifferences)")

var countedPaths = [Int](repeating: 0, count: sortedJoltages.count)
countedPaths[0] = 1 // There's one path that leads to the first joltage (0)
for pathEndIndex in 1...sortedJoltages.count - 1 {
    // Start at the first element right before the current path end
    var pathStartIndex = pathEndIndex - 1
    // Go through all of the valid leading to this joltage adapter
    while pathStartIndex >= 0 && sortedJoltages[pathEndIndex] - sortedJoltages[pathStartIndex] <= 3 {
        // Accumulate the counts from the previous paths into this accumulator
        // since all paths that lead to previous valid joltages also lead to this one
        countedPaths[pathEndIndex] += countedPaths[pathStartIndex]
        // Go backwards through the path one by one
        pathStartIndex -= 1
    }
}
// The total count is whatever the accumulator is at the last item in the path (your device)
print("There are \(countedPaths.last!) distinct paths that can be taken.")
