import Foundation

class Passport {
    var birthYear: Int?
    var issueYear: Int?
    var expirationYear: Int?
    var height: String?
    var hairColor: String?
    var eyeColor: String?
    var passportId: Int?
    var countryId: Int?
    private var validEyeColors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    
    init(rawPassportData: String) {
        do {
            let hairColorMatch = try NSRegularExpression(pattern: #"#[0-9a-f]{6}"#, options: [])
            let passportData = rawPassportData.replacingOccurrences(of: "\n", with: " ").components(separatedBy: " ")
            for passportElement in passportData {
                if (passportElement.count == 0) {
                    continue
                }
                let dataSplit = passportElement.split(separator: ":")
                if (dataSplit.count == 2) {
                    let element = String(dataSplit[0])
                    let data = String(dataSplit[1])
                    switch element {
                    case "byr":
                        let tmp = Int(data)!
                        if (data.count == 4 && tmp >= 1920 && tmp <= 2002) {
                            birthYear = Int(data)
                        }
                    case "iyr":
                        let tmp = Int(data)!
                        if (data.count == 4 && tmp >= 2010 && tmp <= 2020) {
                            issueYear = Int(data)
                        }
                    case "eyr":
                        let tmp = Int(data)!
                        if (data.count == 4 && tmp >= 2020 && tmp <= 2030) {
                            expirationYear = Int(data)
                        }
                    case "hgt":
                        let tmp = Int(data.replacingOccurrences(of: "in", with: "").replacingOccurrences(of: "cm", with: ""))!
                        if (data.contains("in")) {
                            if (tmp >= 59 && tmp <= 76) {
                                height = data
                            }
                        } else if (data.contains("cm")) {
                            if (tmp >= 150 && tmp <= 193) {
                                height = data
                            }
                        }
                    case "hcl":
                        if (hairColorMatch.numberOfMatches(in: data, options: [], range: data.nsRange) == 1) {
                            hairColor = data
                        }
                    case "ecl":
                        if (validEyeColors.contains(data)) {
                            eyeColor = data
                        }
                    case "pid":
                        if (data.count == 9) {
                            passportId = Int(data)
                        }
                    case "cid":
                        countryId = Int(data)
                    default:
                        print("unknown data found: \(element):\(data)")
                    }
                } else {
                    print("unknown data found: \(passportElement)")
                }
            }
        } catch {
            print("error")
        }
    }
    
    func hasAllProperties() -> Bool
    {
        return passportId != nil && eyeColor != nil && hairColor != nil && height != nil && expirationYear != nil && issueYear != nil && birthYear != nil
    }
}
extension String {
    var nsRange: NSRange { return NSRange(location: 0, length: self.utf16.count) }
}

let validationPattern1 = #"(?=byr:[^\s]* *)|(?=iyr:[^\s]* *)|(?=eyr:[^\s]* *)|(?=hgt:[^\s]* *)|(?=hcl:[^\s]* *)|(?=ecl:[^\s]* *)|(?=pid:[^\s]* *)"#
let validationRegex1 = try NSRegularExpression(pattern: validationPattern1, options: [])

func validatePassportWithRule1(rawPassportInfo: String) -> String? {
    let passport = rawPassportInfo.replacingOccurrences(of: "\n", with: " ")
    if (validationRegex1.numberOfMatches(in: passport, options: [], range: passport.nsRange) == 7) {
        return passport
    }
    return nil
}

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

let validPassports1 = problemFile.components(separatedBy: "\n\n").compactMap({ validatePassportWithRule1(rawPassportInfo: $0) })
print("There are \(validPassports1.count) valid passports with rule 1.")

let validPassports2 = problemFile.components(separatedBy: "\n\n").compactMap({ Passport(rawPassportData: $0) }).filter({ $0.hasAllProperties() })
print("There are \(validPassports2.count) valid passports with rule 2.")
