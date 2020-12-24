import Foundation

class Cup: Equatable, CustomStringConvertible {
	static func == (lhs: Cup, rhs: Cup) -> Bool {
		return lhs.number == rhs.number
	}
	
	var number: Int
	var next: Cup?
	var previous: Cup?
	init(_ number: Int) {
		self.number = number
	}
	
	var description: String {
		return "\(self.number)"
	}
	
	func seekFoward(_ number: Int) -> Cup {
		var tmp = self
		while tmp.number != number {
			tmp = tmp.next!
		}
		return tmp
	}
	
	func displayList() -> String {
		var next = self.next
		var str = "(\(self))"
		while next != self {
			str += "\(next!)"
			next = next!.next
		}
		return str
	}
}

func buildCupList(_ cups: [Int]) -> (list: Cup, min: Int, max: Int, dict: [Int:Cup]) {
	let firstCup = Cup(cups[0])
	var c = firstCup
	var cupDict = Dictionary<Int, Cup>()
	cupDict[cups[0]] = firstCup
	for cup in cups[1..<cups.count] {
		let newCup = Cup(cup)
		cupDict[cup] = newCup
		c.next = newCup
		newCup.previous = c
		c = newCup
	}
	c.next = firstCup
	firstCup.previous = c
	return (firstCup, cups.min()!, cups.max()!, cupDict)
}

func cupGameLinkedList(moves: Int, cups: [Int]) {
	var (currentCup, min, max, dict) = buildCupList(cups)
	let startTime = CFAbsoluteTimeGetCurrent()
	for _ in 1...moves {
		// Select the next 3 cups
		let selectedCups = [currentCup.next!, currentCup.next!.next!, currentCup.next!.next!.next!]
		// Splice out the selected cups
		currentCup.next = selectedCups[2].next!
		selectedCups[2].next!.previous! = currentCup
		var cupFinder = currentCup.number - 1
		if cupFinder < min {
			cupFinder = max
		}
		while selectedCups.contains(where: { $0.number == cupFinder }) {
			cupFinder -= 1
			if cupFinder < min {
				cupFinder = max
			}
		}
		// Insert cups in between destination and next neighbor
		let destinationCup = dict[cupFinder]!
		let destinationEndCup = destinationCup.next!
		destinationCup.next = selectedCups[0]
		selectedCups[0].previous = destinationCup
		destinationEndCup.previous = selectedCups[2]
		selectedCups[2].next = destinationEndCup
		// Move on to the next cup after the current one
		currentCup = currentCup.next!
	}
	let cupOne = currentCup.seekFoward(1)
	if (cups.count > 100) {
		let cupTwo = cupOne.next
		let cupThree = cupTwo!.next
		let product = cupTwo!.number * cupThree!.number
		print("After \(moves) moves, the two cups after cup 1 are \(cupTwo!) and \(cupThree!). Their product is \(product).")
	} else {
		print("Resulting cup order after \(moves) moves is \(cupOne.displayList())")
	}
	
	let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
	print("Game took \(timeElapsed) seconds to complete")
}

var testCups: [Int] = [3, 8, 9, 1, 2, 5, 4, 6, 7]
var cups: [Int] = [9, 5, 2, 3, 1, 6, 4, 8, 7]

cupGameLinkedList(moves: 100, cups: testCups)
cupGameLinkedList(moves: 100, cups: cups)

testCups.append(contentsOf: Array((testCups.max()! + 1)...1000000))
cupGameLinkedList(moves: 10000000, cups: testCups)

cups.append(contentsOf: Array((cups.max()! + 1)...1000000))
cupGameLinkedList(moves: 10000000, cups: cups)