import Foundation

func countAdjacentOccupiedSeats(row: Int, seatIndex: Int, seatMap: [[String]]) -> Int {
    var occupiedSeats = 0
    let seatIndexMin = seatIndex - 1 < 0 ? 0 : seatIndex - 1
    let seatIndexMax = seatIndex + 1 > seatMap[row].count - 1 ? seatMap[row].count - 1 : seatIndex + 1
    for newSeatIndex in seatIndexMin...seatIndexMax {
        let rowMin = row - 1 < 0 ? 0 : row - 1
        let rowMax = row + 1 > seatMap.count - 1 ? seatMap.count - 1 : row + 1
        for newSeatRow in rowMin...rowMax {
            if !(newSeatRow == row && newSeatIndex == seatIndex) && seatMap[newSeatRow][newSeatIndex] == "#" {
                occupiedSeats += 1
            }
        }
    }
    return occupiedSeats
}

func countVisibleOccupiedSeats(row: Int, seatIndex: Int, seatMap: [[String]]) -> Int {
    var occupiedSeats = 0
    for seatIndexer in -1...1 {
        for rowIndexer in -1...1 {
            if seatIndexer == 0 && rowIndexer == 0 {
                continue
            }
            var currentSeatIndex = seatIndex + seatIndexer
            var currentRowIndex = row + rowIndexer
            while true {
                if currentSeatIndex < 0 || currentRowIndex < 0 || currentRowIndex > seatMap.count - 1 ||
                    currentSeatIndex > seatMap[currentRowIndex].count - 1 {
                    break
                }
                let visibleSeat = seatMap[currentRowIndex][currentSeatIndex]
                if visibleSeat != "." {
                    if visibleSeat == "#" {
                        occupiedSeats += 1
                    }
                    break
                }
                currentSeatIndex = currentSeatIndex + seatIndexer
                currentRowIndex = currentRowIndex + rowIndexer
            }
        }
    }
    return occupiedSeats
}

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

var seatMap = problemFile.components(separatedBy: "\n")
    .filter({ $0.count > 0 })
    .map{ Array($0).map({ String($0) }) }

let _ = DispatchQueue.global(qos: .userInitiated)

var changes = 1
while changes > 0 {
    changes = 0
    var newSeatMap = seatMap
    for rowIndex in 0...seatMap.count - 1 {
        for seatIndex in 0...seatMap[rowIndex].count - 1 {
            let seat = seatMap[rowIndex][seatIndex]
            if seat != "." {
                let adjacentOccupied = countAdjacentOccupiedSeats(row: rowIndex, seatIndex: seatIndex, seatMap: seatMap)
                // If no adjacent seats are occupied, seat becomes occupied
                if adjacentOccupied == 0 && seat == "L" {
                    newSeatMap[rowIndex][seatIndex] = "#"
                    changes += 1
                } else if adjacentOccupied >= 4 && seat == "#" {
                    newSeatMap[rowIndex][seatIndex] = "L"
                    changes += 1
                }
            }
        }
    }
    seatMap = newSeatMap
}

print("\(seatMap.flatMap({ $0 }).filter({ $0 == "#" }).count) seats are occupied with the adjacent rule")

seatMap = problemFile.components(separatedBy: "\n")
    .filter({ $0.count > 0 })
    .map{ Array($0).map({ String($0) }) }

changes = 1
while changes > 0 {
    changes = 0
    var newSeatMap = seatMap
    for rowIndex in 0...seatMap.count - 1 {
        for seatIndex in 0...seatMap[rowIndex].count - 1 {
            let seat = seatMap[rowIndex][seatIndex]
            if seat != "." {
                let visibleOccupied = countVisibleOccupiedSeats(row: rowIndex, seatIndex: seatIndex, seatMap: seatMap)
                // If no visible seats are occupied, seat becomes occupied
                if visibleOccupied == 0 && seat == "L" {
                    newSeatMap[rowIndex][seatIndex] = "#"
                    changes += 1
                } else if visibleOccupied >= 5 && seat == "#" {
                    newSeatMap[rowIndex][seatIndex] = "L"
                    changes += 1
                }
            }
        }
    }
    seatMap = newSeatMap
}

print("\(seatMap.flatMap({ $0 }).filter({ $0 == "#" }).count) seats are occupied with the visible rule")
