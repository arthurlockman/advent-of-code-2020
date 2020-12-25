import Foundation

func transform(subject: Int, previousValue: Int) -> Int {
	var value = previousValue * subject
	value = value % 20201227
	return value
}

func getEncryptionKey(cardKey: Int, doorKey: Int) -> Int {
	var crackedCardKey = 1
	var crackedDoorKey = 1
	var crackedPublicKey = 1
	while true {
		crackedCardKey = transform(subject: doorKey, previousValue: crackedCardKey)
		crackedDoorKey = transform(subject: cardKey, previousValue: crackedDoorKey)
		crackedPublicKey = transform(subject: 7, previousValue: crackedPublicKey)
		if crackedPublicKey == cardKey {
			return crackedCardKey
		}
		if crackedPublicKey == doorKey {
			return crackedDoorKey
		}
	}
}

var doorKey = 10212254
var cardKey = 12577395
var crackedPubKey = getEncryptionKey(cardKey: cardKey, doorKey: doorKey)
print("Cracked public key is \(crackedPubKey)")