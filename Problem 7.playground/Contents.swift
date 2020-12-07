import Foundation

class Bag {
    var color: String
    var childBags: [String: Int] = [:]
    
    init(bagRule: String) {
        do {
            let separatedRule = bagRule.components(separatedBy: "bags contain")
            color = separatedRule.first!.trimmingCharacters(in: .whitespacesAndNewlines)
            if (!bagRule.contains("no other bags")) {
                let childBagStrings = separatedRule[1].components(separatedBy: ",")
                for bag in childBagStrings {
                    let regex = try NSRegularExpression(pattern: #"(\d+) ([\w| ]+) bags*"#, options: [])
                    if let match = regex.firstMatch(in: bag, options: [], range: NSRange(location: 0, length: bag.utf16.count)) {
                        let bagCount = Int(bag[Range(match.range(at: 1), in: bag)!])!
                        let bagColor = String(bag[Range(match.range(at: 2), in: bag)!]).trimmingCharacters(in: .whitespacesAndNewlines)
                        childBags[bagColor] = bagCount
                    }
                }
            }
        } catch {
            print("Error creating bag")
        }
    }
}

func eventuallyContainsBag(searchColor: String, startBag: Bag, bagRules: [String: Bag]) -> Bool {
    for childBag in startBag.childBags {
        if (childBag.key == searchColor) {
            return true
        }
        
        if let newStartBag = bagRules[childBag.key] {
            if (eventuallyContainsBag(searchColor: searchColor, startBag: newStartBag, bagRules: bagRules)) {
                return true
            }
        }
    }
    return false
}

func countBags(startBag: Bag, bagRules: [String: Bag], start: Bool = true) -> Int {
    return startBag.childBags.map({ $0.value * countBags(startBag: bagRules[$0.key]!, bagRules: bagRules, start: false)}).reduce(0, +) + (start ? 0 : 1)
}

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

let bagRules = Dictionary(uniqueKeysWithValues: problemFile.components(separatedBy: "\n").filter({ $0.count > 0 })
                            .map({ Bag(bagRule: $0) })
                            .map( { ($0.color, $0) }))

print("===Part 1===")
let eventuallyContainsShinyGold = bagRules.map({ eventuallyContainsBag(searchColor: "shiny gold", startBag: $0.value, bagRules: bagRules) }).filter({ $0 })
print("\(eventuallyContainsShinyGold.count) bags eventually contain shiny gold")

print("\n===Part 2===")
let bagCount = countBags(startBag: bagRules["shiny gold"]!, bagRules: bagRules)
print("Shiny gold bags must contain \(bagCount) other bags")
