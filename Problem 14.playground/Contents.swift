import Foundation

extension BinaryInteger {
    var binaryDescription: String {
        var binaryString = ""
        var internalNumber = self
        var counter = 0

        for _ in (1...36) {
            binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
            internalNumber >>= 1
            counter += 1
        }

        return binaryString
    }
}

extension StringProtocol {
    subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: NSRange)                  -> SubSequence { prefix(range.lowerBound+range.length).suffix(range.length) }
    subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
    func replace(_ index: Int, _ newChar: Character) -> String {
        var chars = Array(self)
        chars[index] = newChar
        return String(chars)
    }
    var nsrange: NSRange {
        return NSRange(location: 0, length: self.utf16.count)
    }
}

func applyBitMaskV1(value: Int, bitMask: String) -> Int {
    var valueBitMask = value.binaryDescription
    for i in 0...bitMask.count - 1 {
        let newBit = bitMask[i]
        if (newBit != "X") {
            valueBitMask = valueBitMask.replace(i, newBit)
        }
    }
    return Int(valueBitMask, radix: 2)!
}

func applyBitMaskV2(memoryAddress: Int, bitMask: String) -> [Int] {
    var addressBitMasks = [memoryAddress.binaryDescription]
    for i in 0...bitMask.count - 1 {
        let newBit = bitMask[i]
        if newBit == "1" {
            addressBitMasks = addressBitMasks.map({ $0.replace(i, newBit) })
        } else if newBit == "X" {
            addressBitMasks = addressBitMasks.map({ [$0.replace(i, "0"), $0.replace(i, "1")] }).flatMap({ $0 })
        }
    }
    return addressBitMasks.filter{ !$0.contains("X") }.map{ Int($0, radix: 2)! }
}

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

var memoryV1 = Dictionary<Int, Int>()

let parseRegex = try? NSRegularExpression(pattern: #"mask = (?<mask>\w{36})\n(?:mem\[\d+] = \d+\n?)+"#)
let blockRegex = try? NSRegularExpression(pattern: #"mem\[(?<address>\d+)\] = (?<value>\d+)"#)

for block in parseRegex!.matches(in: problemFile, options: [], range: problemFile.nsrange) {
    let programBlock = String(problemFile[block.range])
    let mask = String(problemFile[block.range(withName: "mask")])
    for memoryValue in blockRegex!.matches(in: programBlock, options: [], range: programBlock.nsrange) {
        let address = Int(programBlock[memoryValue.range(withName: "address")])!
        let value = Int(programBlock[memoryValue.range(withName: "value")])!
        memoryV1[address] = applyBitMaskV1(value: value, bitMask: mask)
    }
}
print("Decoding with a V1 decoder chip gives the sum \(memoryV1.map({ $1 }).reduce(0, +)).")

var memoryV2 = Dictionary<Int, Int>()

for block in parseRegex!.matches(in: problemFile, options: [], range: problemFile.nsrange) {
    let programBlock = String(problemFile[block.range])
    let mask = String(problemFile[block.range(withName: "mask")])
    for memoryValue in blockRegex!.matches(in: programBlock, options: [], range: programBlock.nsrange) {
        let address = Int(programBlock[memoryValue.range(withName: "address")])!
        let value = Int(programBlock[memoryValue.range(withName: "value")])!
        let newAddresses = applyBitMaskV2(memoryAddress: address, bitMask: mask)
        for newAddress in newAddresses {
            memoryV2[newAddress] = value
        }
    }
}

print("Decoding with a V2 decoder chip gives the sum \(memoryV2.map({ $1 }).reduce(0, +)).")
