import Foundation

extension StringProtocol {
	var nsrange: NSRange {
		return NSRange(location: 0, length: self.utf16.count)
	}
}

class Rule {
	var id: Int
	var rules: [Int]? = nil
	var or: [[Int]]? = nil
	var char: String? = nil
	
	init(ruleString: String) {
		let ruleSplit = ruleString.components(separatedBy: ": ")
		id = Int(ruleSplit[0])!
		if ruleSplit[1].contains("\"") {
			char = ruleSplit[1].replacingOccurrences(of: "\"", with: "")
		} else if ruleSplit[1].contains("|") {
			let orSplit = ruleSplit[1].components(separatedBy: "|")
			self.or = []
			for or in orSplit {
				self.or?.append(or.components(separatedBy: .whitespaces).filter { $0.count > 0 }.map { Int($0)! })
			}
		} else {
			rules = ruleSplit[1].components(separatedBy: .whitespaces).filter { $0.count > 0 }.map { Int($0)! }
		}
	}
	
	func getRegexString(allRules: Dictionary<Int, Rule>) -> String {
		var regex = #""#
		if char != nil {
			regex = "\(char!)"
		} else if rules != nil {
			for ruleId in rules! {
				let rule = allRules[ruleId]
				regex += rule!.getRegexString(allRules: allRules)
			}
		} else if or != nil {
			var ors: [String] = []
			for orSet in or! {
				var orRegex = #""#
				for ruleId in orSet {
					let rule = allRules[ruleId]
					orRegex += rule!.getRegexString(allRules: allRules)
				}
				ors.append(orRegex)
			}
			regex = "(\(ors.joined(separator: "|")))"
		}
		return regex
	}
}

func parseRules(file: String, startingRule: Int = 0) -> NSRegularExpression {
	let rules = file.components(separatedBy: "\n\n")[0]
				.components(separatedBy: .newlines)
				.map { Rule(ruleString: $0) }
				.reduce(into: [Int:Rule]()) {
					$0[$1.id] = $1
				}
	let ruleRegex = rules[startingRule]!.getRegexString(allRules: rules)
	return try! NSRegularExpression(pattern: "^\(ruleRegex)$", options: [.anchorsMatchLines])
}

let problemFile = String(try NSString(contentsOfFile: "./input.txt", encoding: String.Encoding.ascii.rawValue))
let problemFilePart2 = String(try NSString(contentsOfFile: "./input-modified.txt", encoding: String.Encoding.ascii.rawValue))

let testFile = 
"""
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb
"""

let testRule = parseRules(file: testFile)
let testMatches = testRule.matches(in: testFile, options: [], range: testFile.nsrange).count
print("\(testMatches) messages match the test rules (should be 2)")

let realRule = parseRules(file: problemFile)
let matches = realRule.matches(in: problemFile, options: [], range: problemFile.nsrange).count
print("\(matches) messages match the problem file rules")

let part2Rule = parseRules(file: problemFilePart2)
let matchesPart2 = part2Rule.matches(in: problemFilePart2, options: [], range: problemFilePart2.nsrange).count
print("\(matchesPart2) messages match the problem file rules for part 2")