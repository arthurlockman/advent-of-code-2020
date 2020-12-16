import Foundation

extension StringProtocol {
    subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: NSRange)                  -> SubSequence { prefix(range.lowerBound+range.length).suffix(range.length) }
    subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
    var nsrange: NSRange {
        return NSRange(location: 0, length: self.utf16.count)
    }
}

class Rule {
    var range1: ClosedRange<Int>
    var range2: ClosedRange<Int>
    var fieldName: String
    
    init(ruleString: String) {
        let parseRegex = try? NSRegularExpression(pattern: #"(?<field>[\w\s]+): (?<range1lower>\d+)-(?<range1upper>\d+) or (?<range2lower>\d+)-(?<range2upper>\d+)"#)
        let matches = parseRegex?.matches(in: ruleString, options: [], range: ruleString.nsrange)[0]
        range1 = Int(ruleString[matches!.range(withName: "range1lower")])!...Int(ruleString[matches!.range(withName: "range1upper")])!
        range2 = Int(ruleString[matches!.range(withName: "range2lower")])!...Int(ruleString[matches!.range(withName: "range2upper")])!
        fieldName = String(ruleString[matches!.range(withName: "field")])
    }
    
    func validate(fieldValue: Int) -> Bool {
        return range1.contains(fieldValue) || range2.contains(fieldValue)
    }
}

class Ticket {
    var fields: [Int]
    
    init(ticketString: String) {
        fields = ticketString.components(separatedBy: ",").map { Int($0)! }
    }
    
    func validate(rules: [Rule]) -> Int {
        var errorRate = 0
        for field in fields {
            var valid = false
            for rule in rules {
                valid = valid || rule.validate(fieldValue: field)
            }
            if !valid {
                errorRate += field
            }
        }
        return errorRate
    }
    
    func getFieldOrder(rules: [Rule]) -> [ Set<String> ] {
        var result: [Set<String>] = []
        for field in fields {
            result.append(Set(rules.compactMap( { $0.validate(fieldValue: field) ? $0.fieldName : nil} )))
        }
        return result
    }
}

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

let rules = problemFile.components(separatedBy: "\n\n")[0].components(separatedBy: "\n")
    .filter { $0.count > 0 }
    .map { Rule(ruleString: $0) }

let nearbyTickets = problemFile.components(separatedBy: "nearby tickets:\n")[1].components(separatedBy: "\n")
    .filter { $0.count > 0 }
    .map { Ticket(ticketString: $0) }
let validatedTickets = nearbyTickets.map { ($0.validate(rules: rules), $0) }

print("Scanning error rate is", validatedTickets.map({ $0.0 }).reduce(0, +))

let possibleFieldOrders = validatedTickets.filter { $0.0 == 0 }
    .map { $0.1.getFieldOrder(rules: rules)}

var fieldOrder: [(Int, Set<String>)] = []
for i in 0...possibleFieldOrders[0].count - 1 {
    var possibleValues = possibleFieldOrders[0][i]
    for j in 1...possibleFieldOrders.count - 1 {
        possibleValues = possibleValues.intersection(possibleFieldOrders[j][i])
    }
    fieldOrder.append((i, possibleValues))
}
fieldOrder.sort(by: { $0.1.count < $1.1.count })

var finalFieldOrder: [(Int, String)] = []
var usedFields: [String] = []
for field in fieldOrder {
    let difference = field.1.symmetricDifference(usedFields)
    usedFields.append(difference.first!)
    finalFieldOrder.append((field.0, difference.first!))
}

print("Final field order is \(finalFieldOrder.sorted(by: { $0.0 < $1.0 }).map{ $0.1 })")

let myTicket = Ticket(ticketString: "97,61,53,101,131,163,79,103,67,127,71,109,89,107,83,73,113,59,137,139")
let chosenFields = finalFieldOrder.filter { $0.1.starts(with: "departure") }
var result = 1
for field in chosenFields {
    print("Field \(field.1) in my ticket has value \(myTicket.fields[field.0])")
    result *= myTicket.fields[field.0]
}
print("The final multiplication result is \(result)")
