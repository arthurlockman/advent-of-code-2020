import Foundation

let problemFile = String(try NSString(contentsOfFile: "./input.txt", encoding: String.Encoding.ascii.rawValue))

let testFile = """
mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)
"""

func parseFoodData(_ problemData: String) -> 
		(foodData: [(Set<String>, Set<String>)], allergens: Set<String>, allergensToFoods: Dictionary<String, Set<String>>) {
	var foodData = [(Set<String>, Set<String>)]()
	for recipe in problemData.components(separatedBy: .newlines) {
		let split = recipe.components(separatedBy: " (contains ")
		let ingredients = split[0].components(separatedBy: .whitespaces)
		let allergens = split[1].replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")
		foodData.append((Set(ingredients), Set(allergens)))
	}
	
	let allergens = foodData.map{ $1 }.reduce(Set<String>()) { $0.union($1) }
	
	var allergenMap = Dictionary<String, Set<String>>()
	for allergen in allergens {
		var possibleIngredients: Set<String>? = nil
		for food in foodData {
			if food.1.contains(allergen) {
				if possibleIngredients == nil {
					possibleIngredients = food.0
				} else {
					possibleIngredients = possibleIngredients?.intersection(food.0)
				}
			}
		}
		allergenMap[allergen] = possibleIngredients
	}
	
	return (foodData, allergens, allergenMap)
}

func countNonAllergicIngredients(_ problemData: String) -> Int {
	let data = parseFoodData(problemData)
	let allAllergicIngredients = data.allergensToFoods.map { $0.value }.reduce(Set<String>()) { $0.union($1) }
	let nonAllergicIngredientCounts = data.foodData.map { $0.0.subtracting(allAllergicIngredients).count }
	return nonAllergicIngredientCounts.reduce(0, +)
}

func findAllergicIngredientsList(_ problemData: String) -> String {
	let data = parseFoodData(problemData)
	var usedIngredients = Set<String>()
	var allergenToIngredientMap: [(allergen: String, ingredient: String)] = []
	var consumedValue = true
	while consumedValue {
		consumedValue = false
		for allergenMap in data.allergensToFoods.sorted(by: { $0.value.count < $1.value.count }) {
			let availableIngredients = allergenMap.value.subtracting(usedIngredients)
			if availableIngredients.count == 1 {
				allergenToIngredientMap.append((allergenMap.key, availableIngredients.first!))
				usedIngredients.insert(availableIngredients.first!)
				consumedValue = true
			}
		}
	}
	return allergenToIngredientMap.sorted(by: { $0.allergen < $1.allergen }).map({ $0.ingredient }).joined(separator: ",")
}

print("Non-allergic ingredients appear in test file \(countNonAllergicIngredients(testFile)) times (should be 5)")
print("Non-allergic ingredients appear in real file \(countNonAllergicIngredients(problemFile)) times")

print("Food allergen list in test file is \(findAllergicIngredientsList(testFile)) (should be 'mxmxvkd,sqjhc,fvjkl')")
print("Food allergen list in real file is \(findAllergicIngredientsList(problemFile))")