import Foundation

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

class BoardingPass {
    var row: Int
    var column: Int
    var seatID: Int { return row * 8 + column }
    
    init(boardingPass: String) {
        var rowMin = 0.0
        var rowMax = 127.0
        for i in 0...6 {
            let half = (rowMax - rowMin) / 2.0
            if (boardingPass[i] == "F") {
                rowMax = rowMax - half
            } else if (boardingPass[i] == "B") {
                rowMin = rowMin + half
            }
        }
        row = Int(ceil(rowMin))
        var colMin = 0.0
        var colMax = 8.0
        for i in 7...9 {
            let half = (colMax - colMin) / 2.0
            if (boardingPass[i] == "L") {
                colMax = colMax - half
            } else if (boardingPass[i] == "R") {
                colMin = colMin + half
            }
        }
        column = Int(ceil(colMin))
    }
}
let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

let boardingPasses = problemFile.components(separatedBy: "\n")
    .compactMap({ $0.count > 0 ? BoardingPass(boardingPass: $0) : nil })
    .sorted(by: { $0.seatID > $1.seatID })

print("The highest seat ID is \(boardingPasses.first!.seatID).")

let ids = boardingPasses.map({ $0.seatID })
var allIds = Array(boardingPasses.last!.seatID...boardingPasses.first!.seatID)
var missing = ids.difference(from: allIds)
print("Your seat is \(missing.first!).")
