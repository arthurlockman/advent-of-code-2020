import Foundation

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

let preambleLength = 25
var numbers = problemFile.components(separatedBy: "\n")
    .filter({ $0.count > 0 })
    .map({ Int($0)! })

var matchingNumber = -1

for i in preambleLength...numbers.count - 1 {
    let number = numbers[i]
    let previousNumbers = numbers[i - 25...i - 1]
    var matchesRule = false
    for previous1 in previousNumbers {
        for previous2 in previousNumbers {
            if previous1 != previous2 && previous1 + previous2 == number {
                matchesRule = true
            }
        }
    }
    if !matchesRule {
        print("\(number) does not match rule (preamble length of \(preambleLength))")
        matchingNumber = number
        break
    }
}

for i in 0...numbers.count - 1 {
    for j in i...numbers.count - 1 {
        let range = numbers[i...j]
        if (range.max()! < matchingNumber) {
            let sum = range.reduce(0, +)
            if (sum == matchingNumber) {
                print("Found matching range (sum \(sum) == \(matchingNumber))")
                print("Smallest number in range: \(range.min()!)")
                print("Largest number in range: \(range.max()!)")
                print("Sum of smallest and largest: \(range.min()! + range.max()!)")
                break
            }
        }
    }
}
