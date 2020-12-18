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
    /// stringToFind must be at least 1 character.
    func countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: stringToFind, options: [], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
}

func evaluateExpression(_ expressionString: String) -> Int {
    let innerExpressionRegex = try? NSRegularExpression(pattern: #"\((?<expression>(?:\d+ [\+|\*] )+\d)\)"#)
    var newExpression = expressionString
    var expressionMatches = innerExpressionRegex?.matches(in: newExpression, options: [], range: newExpression.nsrange)
    
    // There appear to be inner expressions here - let's evaluate them
    while expressionMatches?.count ?? 0 > 0 {
        let match = expressionMatches![0]
        let expressionRange = match.range(withName: "expression")
        let replaceRange = match.range
        let innerExpression = newExpression[expressionRange]
        let result = evaluateExpression(String(innerExpression))
        newExpression = (newExpression as NSString).replacingCharacters(in: replaceRange, with: String(result))
        expressionMatches = innerExpressionRegex?.matches(in: newExpression, options: [], range: newExpression.nsrange)
    }
    
    let operatorCount = newExpression.countInstances(of: "+") + newExpression.countInstances(of: "*")
    
    if operatorCount > 1 {
        // There's more than one expression here - we need to keep flattening it to do this in order
        let expressionRegex = try? NSRegularExpression(pattern: #"(?<expression>\d+ [\+|\*] \d+)"#)
        var matches = expressionRegex?.matches(in: newExpression, options: [], range: newExpression.nsrange)
        while matches?.count ?? 0 > 0 {
            let match = matches![0]
            let expressionRange = match.range(withName: "expression")
            let innerExpression = newExpression[expressionRange]
            let result = evaluateExpression(String(innerExpression))
            newExpression = (newExpression as NSString).replacingCharacters(in: expressionRange, with: String(result))
            matches = expressionRegex?.matches(in: newExpression, options: [], range: newExpression.nsrange)
        }
    }
    
    // Now we're really at a 1 + 1 like expression - evaluate it and return
    let expression = NSExpression(format: newExpression)
    return (expression.expressionValue(with: nil, context: nil) as? Int)!
}

let testExpressions: [(String, Int)] = [
    ("1 + 2 * 3 + 4 * 5 + 6", 71),
    ("1 + (2 * 3) + (4 * (5 + 6))", 51),
    ("2 * 3 + (4 * 5)", 26),
    ("5 + (8 * 3 + 9 + 3 * 4 * 3)", 437),
    ("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 12240),
    ("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 13632)
]

for test in testExpressions {
    print("\(test.0) should evaluate to \(test.1). Result is \(evaluateExpression(test.0)).")
}

let problemFile = String(try NSString(contentsOfFile: "./Problem 18 Input.txt", encoding: String.Encoding.ascii.rawValue))
let expressions = problemFile.components(separatedBy: "\n")
let results = expressions.map { evaluateExpression($0) }
print(expressions.count, results.count)
print("The sum of all expressions in the homework file is \(results.reduce(0, +))")

// 25176959584842 is wrong