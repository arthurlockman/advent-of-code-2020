import Foundation

enum ExecutionError: Error {
    case infiniteLoop(programCounterState: Int)
}

enum InstructionType {
    case nop
    case jmp
    case acc
}

class Instruction {
    var executionCount: Int = 0
    var action: InstructionType
    var index: Int
    var adder: Int
    
    init(instruction: String, programIndex: Int) {
        index = programIndex
        let splitInstruction = instruction.components(separatedBy: " ")
        switch splitInstruction[0] {
        case "jmp":
            action = InstructionType.jmp
        case "acc":
            action = InstructionType.acc
        case "nop":
            action = InstructionType.nop
        default:
            action = InstructionType.nop
        }
        adder = Int(splitInstruction[1].replacingOccurrences(of: "+", with: ""))!
    }
    
    func execute(programCounter: Int) throws -> (programCounter: Int, nextIndex: Int) {
        if executionCount > 0 {
            throw ExecutionError.infiniteLoop(programCounterState: programCounter)
        }
        executionCount += 1
        switch action {
        case .jmp:
            return (programCounter, index + adder)
        case .nop:
            return (programCounter, index + 1)
        case .acc:
            return (programCounter + adder, index + 1)
        }
    }
    
    func flipFlopInstruction()
    {
        switch action{
        case .jmp:
            action = InstructionType.nop
        case .nop:
            action = InstructionType.jmp
        case .acc:
            break
        }
    }
}

func runProgram(instructions: [Instruction]) -> Int? {
    var programIndex = 0
    var programCounter: Int? = 0
    while programIndex < instructions.count {
        do {
            let result = try instructions[programIndex].execute(programCounter: programCounter!)
            programIndex = result.nextIndex
            programCounter = result.programCounter
        } catch ExecutionError.infiniteLoop(let programCounterState) {
            print("Encountered an infinite loop while executing (at index \(programIndex)), program counter was \(programCounterState).")
            programCounter = nil
            break
        } catch {
            print("Encountered an unknown error while executing (at index \(programIndex)).")
            programCounter = nil
            break
        }
    }
    return programCounter
}

let path = Bundle.main.path(forResource: "input", ofType: "txt")
let problemFile = try! String(contentsOfFile: path!)

let instructions = problemFile.components(separatedBy: "\n")
    .filter({ $0.count > 0 }).enumerated()
    .map({ (index, element) in Instruction(instruction: element, programIndex: index) })

runProgram(instructions: instructions)

print("Attempting to fix program...")
for i in 0...(instructions.count - 1) {
    let newInstructions = problemFile.components(separatedBy: "\n")
        .filter({ $0.count > 0 }).enumerated()
        .map({ (index, element) in Instruction(instruction: element, programIndex: index) })
    let originalAction = newInstructions[i].action
    if (originalAction != InstructionType.acc) {
        newInstructions[i].flipFlopInstruction()
        let newAction = newInstructions[i].action
        let resultCounter = runProgram(instructions: newInstructions)
        if (resultCounter != nil) {
            print("Program executed successfully! Resulting counter was \(resultCounter!). Changed \(originalAction) at index \(i) to \(newAction).")
            break
        }
    }
}
