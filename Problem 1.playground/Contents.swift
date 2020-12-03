import Foundation

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)
let numbers = problemFile.components(separatedBy: "\n").compactMap { Int($0) }

print("====Part 1====")
mainLoop1: for number1 in numbers {
    if let number2 = numbers.first(where: { $0 == 2020 - number1 }) {
        print("The two numbers are \(number1) and \(number2). Their product is \(number1 * number2).")
        break mainLoop1
    }
}

print("\n====Part 2====")
mainloop2: for number1 in numbers {
    for number2 in numbers.filter({ $0 != number1 }) {
        for number3 in numbers.filter({ $0 != number1 && $0 != number2 }) {
            if (number1 + number2 + number3 == 2020) {
                print("The thre numbers are \(number1), \(number2), and \(number3). Their product is \(number1 * number2 * number3).")
                break mainloop2
            }
        }
    }
}
