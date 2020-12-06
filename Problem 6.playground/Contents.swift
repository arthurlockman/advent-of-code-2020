import Foundation

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

print("===Part 1===")

let groupYesCounts = problemFile.components(separatedBy: "\n\n")
    .map({ $0.replacingOccurrences(of: "\n", with: "") })
    .map({ Set($0).count })
print("The sum of counts of \"yes\" answered questions is \(groupYesCounts.reduce(0, +))")

print("\n===Part 2===")

let groupCommonCounts = problemFile.components(separatedBy: "\n\n")
    .map({ $0.components(separatedBy: "\n" ) })
    .map({ (group: [String]) -> Int in
        var set = Set(group.first!)
        if (group.count > 1) {
            for person in group.filter({ $0.count > 0 }) {
                set = set.filter(Set(person).contains)
            }
        }
        return set.count
    })

print("The sum of counts of commonly answered questions is \(groupCommonCounts.reduce(0, +))")
