import Foundation

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

func countTrees(map: [String], down: Int, right: Int) -> Int {
    var trees = 0
    var x = 0
    for y in stride(from: down, to: mapRows.count - 1, by: down) {
        let row = mapRows[y]
        if (row.count > 0) {
            x += right
            if (x > row.count - 1) {
                x = x - row.count
            }
            if (row[x] == "#") {
                trees += 1
            }
        }
    }
    return trees
}

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

let mapRows = problemFile.components(separatedBy: "\n")

print("====Part 1====")

var count_3_1_1 = countTrees(map: mapRows, down: 1, right: 3)
print("Encountered \(count_3_1_1) trees when traveling on a (-3, -1, 1) path.")

print("\n====Part 2====")
var count_1_1_1 = countTrees(map: mapRows, down: 1, right: 1)
var count_5_1_1 = countTrees(map: mapRows, down: 1, right: 5)
var count_7_1_1 = countTrees(map: mapRows, down: 1, right: 7)
var count_1_2_1 = countTrees(map: mapRows, down: 2, right: 1)
print("Product of all trees encountered is \(count_3_1_1 * count_1_1_1 * count_5_1_1 * count_7_1_1 * count_1_2_1)")
