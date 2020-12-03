import Foundation

extension Bool {
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}

let pattern = #"(\d+)-(\d+) (\w+): (.*)"#
let regex = try NSRegularExpression(pattern: pattern, options: [])

func parsePassword(passwordEntry: String) -> (Int, Int, String, String)? {
    if let match = regex.firstMatch(in: passwordEntry, options: [], range: NSRange(location: 0, length: passwordEntry.utf16.count)) {
        var lowerMatch = 0
        var upperMatch = 0
        var character = ""
        var password = ""
        if let lowerRange = Range(match.range(at: 1), in: passwordEntry) {
            lowerMatch = Int(passwordEntry[lowerRange])!
        }
        if let upperRange = Range(match.range(at: 2), in: passwordEntry) {
            upperMatch = Int(passwordEntry[upperRange])!
        }
        if let characterRange = Range(match.range(at: 3), in: passwordEntry) {
            character = String(passwordEntry[characterRange])
        }
        if let passwordRange = Range(match.range(at: 4), in: passwordEntry) {
            password = String(passwordEntry[passwordRange])
        }
        return (lowerMatch, upperMatch, character, password)
    }
    return nil
}

func validPasswordWithPolicy1(password: (lower: Int, upper: Int, char: String, pwd: String)) -> Bool {
    let charCount = password.pwd.components(separatedBy: password.char).count - 1
    return password.lower <= charCount && charCount <= password.upper
}

func validPasswordWithPolicy2(password: (lower: Int, upper: Int, char: String, pwd: String)) -> Bool {
    let pwd = password.pwd
    let char1 = String(pwd[pwd.index(pwd.startIndex, offsetBy: password.lower - 1)])
    let char2 = String(pwd[pwd.index(pwd.startIndex, offsetBy: password.upper - 1)])
    return (char1 == password.char) ^ (char2 == password.char)
}

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

let passwords = problemFile.components(separatedBy: "\n").compactMap { parsePassword(passwordEntry: $0)}

print("====Part 1====")
print("There are \(passwords.filter({ validPasswordWithPolicy1(password: $0) }).count) valid passwords.")

print("====Part 2====")
print("There are \(passwords.filter({ validPasswordWithPolicy2(password: $0) }).count) valid passwords.")
