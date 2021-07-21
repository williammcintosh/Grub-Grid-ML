import Foundation

struct RatingObj: Identifiable {
  var index: String = ""
  var user_id: String = ""
  var recipe_id: String = ""
  var rating: String = ""
  var id = UUID()
  
  init(raw: [String]) {
    index = raw[0]
    user_id = raw[1]
    recipe_id = raw[2]
    rating = raw[3]
  }
}

struct RecipeObj: Identifiable {
  //0="index",1="name",2="receip_id",3="minutes",4="nutrition",5="n_steps",6="steps",7="description",8="ingredients",9="n_ingredients"
  var index: Int = 0
  var name: String = ""
  var recipe_id: Int = 0
  var minutes: Int = 0
  var nutrition: [Float] = []
  var n_steps: Int = 0
  var steps: [String] = []
  var description: String = ""
  var ingredients: [String] = []
  var n_ingredients: Int = 0
  var id = UUID()
  
  init(raw: [String]) {
    index = Int(raw[0].replacingOccurrences(of: "\"", with: "")) ?? 0
    name = raw[1]
    recipe_id = Int(raw[2].replacingOccurrences(of: "\"", with: "")) ?? index
    minutes = Int(raw[3].replacingOccurrences(of: "\"", with: "")) ?? 15
    nutrition = ConvertStringToArrayOfFloats(rawData: raw[4])
    n_steps = Int(raw[5].replacingOccurrences(of: "\"", with: "")) ?? 5
    steps = ConvertStringToArrayOfStrings(rawData: raw[6])
    description = raw[7]
    ingredients = ConvertStringToArrayOfStrings(rawData: raw[8])
    n_ingredients = Int(raw[8].replacingOccurrences(of: "\"", with: "")) ?? 5
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


func loadRatingCSV(from csvName: String) -> [RatingObj] {
  var csvToStruct = [RatingObj]()
  
  //locate the csv file
  guard let filePath = Bundle.main.path(forResource: csvName, ofType: "csv") else {
    return []
  }
  
  //convert contents of file to a very long string
  var data = ""
  do {
    data = try String(contentsOfFile: filePath)
  } catch {
    print(error)
    return []
  }
  
  //split the long string into rows
  var rows = data.components(separatedBy: "\n")
  
  //Count number of columns
  let columnCount = rows.first?.components(separatedBy: ",").count
  //Removes headers
  rows.removeFirst()
  
  //split each row into columns
  for row in rows {
    let csvColumns = row.components(separatedBy: ",")
    if csvColumns.count == columnCount {
      let testStruct = RatingObj.init(raw: csvColumns)
      csvToStruct.append(testStruct)
    }
  }
  
  return csvToStruct
}

func loadRecipeCSV(from csvName: String) -> [RecipeObj] {
  var csvToStruct = [RecipeObj]()
  
  //locate the csv file
  guard let filePath = Bundle.main.path(forResource: csvName, ofType: "csv") else {
    return []
  }
  
  //convert contents of file to a very long string
  var data = ""
  do {
    data = try String(contentsOfFile: filePath)
  } catch {
    print(error)
    return []
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
      let testStruct = RecipeObj.init(raw: csvColumns)
      csvToStruct.append(testStruct)
    }
  }
  
  return csvToStruct
}
