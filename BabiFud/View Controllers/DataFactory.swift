import Foundation

struct RatingObj: Identifiable {
  var user_id: Int64 = 0
  var recipe_id: Int64 = 0
  var rating: Int64 = 0
  var freq: Int64 = 0
  var id = UUID()
  
  init(raw: [String]) {
    user_id = Int64(raw[1]) ?? 0
    recipe_id = Int64(raw[2]) ?? 0
    rating = Int64(raw[3]) ?? 0
    freq = Int64(raw[4]) ?? 0
  }
}

struct RecipeObj: Identifiable {
  var name: String = ""
  var recipe_id: Int = 0
  var steps: [String] = []
  var ingredients: [String] = []
  var id = UUID()
  
  init(raw: [String]) {
    name = raw[1]
    recipe_id = Int(raw[2].replacingOccurrences(of: "\"", with: "")) ?? 0
    steps = ConvertStringToArrayOfStrings(rawData: raw[3])
    ingredients = ConvertStringToArrayOfStrings(rawData: raw[4])
  }
}

func ConvertStringToArrayOfFloats(rawData: String) -> [Float] {
  var arrayFloats: [Float] = []
  //Removes unwanted characters from 'nutrition' string of floats
  let nutStr = rawData.replacingOccurrences(of: "[\\[\\]^+<>]", with: "", options: .regularExpression, range: nil)
  //Separates string into an array of strings
  let arrStr = nutStr.components(separatedBy: ",")
  //Converts each string into a float and appends it onto the nutrition[]
  for i in arrStr {
    arrayFloats.append(Float(i) ?? 0.0)
  }
  return arrayFloats
}

func ConvertStringToArrayOfStrings(rawData: String) -> [String] {
  var arrayStr: [String] = []
  var thing: String
  //Removes unwanted characters from 'nutrition' string of floats
  let initStr = rawData.replacingOccurrences(of: "[\\[\\]^+<>]", with: "", options: .regularExpression, range: nil)
  //Separates string into an array of strings
  let arrStr = initStr.components(separatedBy: ",")
  //Converts each string into a float and appends it onto the nutrition[]
  for iStr in arrStr {
    thing = iStr.replacingOccurrences(of: "[\\[\\]^'+<>]", with: "", options: .regularExpression, range: nil)
    arrayStr.append(thing)
  }
  return arrayStr
}


func loadRatingCSV(from csvName: String) {
  //locate the csv file
  guard let filePath = Bundle.main.path(forResource: csvName, ofType: "csv") else {
    return
  }
  //convert contents of file to a very long string
  var data = ""
  do {
    data = try String(contentsOfFile: filePath)
  } catch {
    print(error)
    return
  }
  //split the long string into rows
  var rows = data.components(separatedBy: "\n")
  //Count number of columns
  let columnCount = rows.first?.components(separatedBy: ",").count
  //Removes headers
  rows.removeFirst()
  //split each row into columns
  for r in 0..<rows.count {
    let csvColumns = rows[r].components(separatedBy: ",")
    if csvColumns.count == columnCount {
      if r == 0 {
        let newRating = RatingObj.init(raw: csvColumns)
        DetailTableViewController().UploadRatingToCKRecord(myRat: newRating, count: String(r))
      }
    }
  }
}

func loadRecipeCSV(from csvName: String){
  //locate the csv file
  guard let filePath = Bundle.main.path(forResource: csvName, ofType: "csv") else {
    return
  }
  //convert contents of file to a very long string
  var data = ""
  do {
    data = try String(contentsOfFile: filePath)
  } catch {
    print(error)
    return
  }
  //split the long string into rows
  var rows = data.components(separatedBy: "\n")
  //Count number of columns
  let columnCount = rows.first?.components(separatedBy: "\",\"").count
  //Removes headers
  rows.removeFirst()
  //split each row into columns
  for row in rows {
    let csvColumns = row.components(separatedBy: "\",\"")
    if csvColumns.count == columnCount {
      let newRecipe = RecipeObj.init(raw: csvColumns)
      DetailTableViewController().UploadRecipeToCKRecord(recipe: newRecipe, count: String(row))
    }
  }
}
