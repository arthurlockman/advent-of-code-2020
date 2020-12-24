import Foundation

func playCombat(player1: [Int], player2: [Int]) {
	var p1deck = player1
	var p2deck = player2
	print("== Pre-game report ==")
	print("Player 1's deck: \(p1deck.map{ String($0) }.joined(separator: ", "))")
	print("Player 2's deck: \(p2deck.map{ String($0) }.joined(separator: ", "))")
	while !p1deck.isEmpty && !p2deck.isEmpty {        
		let p1card = p1deck.removeFirst()
		let p2card = p2deck.removeFirst()
		if p1card > p2card {
			p1deck.append(p1card)
			p1deck.append(p2card)
		} else if p2card > p1card {
			p2deck.append(p2card)
			p2deck.append(p1card)
		}
	}
	print("\n== Post-game results ==")
	print("Player 1's deck: \(p1deck.map{ String($0) }.joined(separator: ", "))")
	print("Player 2's deck: \(p2deck.map{ String($0) }.joined(separator: ", "))")
	let winningDeck = p1deck.isEmpty ? p2deck : p1deck
	let score = winningDeck.enumerated().map { $1 * (winningDeck.count - $0) }.reduce(0, +)
	print("Winning score: \(score)")
}

func playRecursiveCombat(player1: [Int], player2: [Int], gameNumber: Int = 1) -> Int {
	var p1Deck = player1
	var p2Deck = player2
	if gameNumber == 1 {
		print("== Pre-game report (Game \(gameNumber)) ==")
		print("Player 1's deck: \(p1Deck.map{ String($0) }.joined(separator: ", "))")
		print("Player 2's deck: \(p2Deck.map{ String($0) }.joined(separator: ", "))")
	}
	
	var p1Decks: [[Int]] = []
	var p2Decks: [[Int]] = []
	roundLoop: while !p1Deck.isEmpty && !p2Deck.isEmpty {
		// if there was a previous round in this game that had exactly the same cards in the same 
		// order in the same players' decks, the game instantly ends in a win for player 1
		if p1Decks.contains(p1Deck) && p2Decks.contains(p2Deck) {
			break roundLoop
		}
		p1Decks.append(p1Deck)
		p2Decks.append(p2Deck)
		
		let p1Card = p1Deck.removeFirst()
		let p2Card = p2Deck.removeFirst()
		
		// If both players have at least as many cards remaining in their 
		// deck as the value of the card they just drew, the winner of the
		// round is determined by playing a new game of Recursive Combat
		var roundWinner = 0
		if p1Deck.count >= p1Card && p2Deck.count >= p2Card {
			let deck1Copy = Array(p1Deck[0..<p1Card])
			let deck2Copy = Array(p2Deck[0..<p2Card])
			roundWinner = playRecursiveCombat(player1: deck1Copy, player2: deck2Copy, gameNumber: gameNumber + 1)
		} else {
			// the winner of the round is the player with the higher-value card
			if p1Card > p2Card {
				roundWinner = 1
			} else if p2Card > p1Card {
				roundWinner = 2
			}
		}
		
		if roundWinner == 1 {
			p1Deck.append(p1Card)
			p1Deck.append(p2Card)
		} else if roundWinner == 2 {
			p2Deck.append(p2Card)
			p2Deck.append(p1Card)
		}
	}
	let winner = p1Deck.isEmpty ? 2 : 1
	let winningDeck = p1Deck.isEmpty ? p2Deck : p1Deck
	let score = winningDeck.enumerated().map { $1 * (winningDeck.count - $0) }.reduce(0, +)
	if gameNumber == 1 {
		print("\n== Post-game results ==")
		print("Player 1's deck: \(p1Deck.map{ String($0) }.joined(separator: ", "))")
		print("Player 2's deck: \(p2Deck.map{ String($0) }.joined(separator: ", "))")
		print("The winner of game \(gameNumber) is player \(winner)")
		print("Winning score: \(score)")
	}
	return p1Deck.isEmpty ? 2 : 1;
}


let player1TestDeck = """
9
2
6
3
1
""".components(separatedBy: .newlines).map({ Int($0)! })

let player2TestDeck = """
5
8
4
7
10
""".components(separatedBy: .newlines).map({ Int($0)! })

let player1RecursionTestDeck = """
43
19
""".components(separatedBy: .newlines).map({ Int($0)! })

let player2RecursionTestDeck = """
2
29
14
""".components(separatedBy: .newlines).map({ Int($0)! })

let player1Deck = """
25
37
35
16
9
26
17
5
47
32
11
43
40
15
7
19
36
20
50
3
21
34
44
18
22
""".components(separatedBy: .newlines).map({ Int($0)! })

let player2Deck = """
12
1
27
41
4
39
13
29
38
2
33
28
10
6
24
31
42
8
23
45
46
48
49
30
14
""".components(separatedBy: .newlines).map({ Int($0)! })

playCombat(player1: player1TestDeck, player2: player2TestDeck)

playCombat(player1: player1Deck, player2: player2Deck)

let _ = playRecursiveCombat(player1: player1TestDeck, player2: player2TestDeck)
let _ = playRecursiveCombat(player1: player1RecursionTestDeck, player2: player2RecursionTestDeck)
let _ = playRecursiveCombat(player1: player1Deck, player2: player2Deck)