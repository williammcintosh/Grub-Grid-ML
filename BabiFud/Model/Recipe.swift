
import Foundation
import UIKit
import MapKit
import CloudKit
import CoreLocation

class Recipe {
  
  static let recordType = "Recipe"
  private let id: CKRecord.ID
  let database: CKDatabase
  let recipeURL: String
  let name: String
  //let description: String
  let recipe_id: Int64
  let ingredients: [String]
  //let minutes: Int64
  //let n_steps: Int64
  let steps: [String]
  private(set) var notes: [Note]? = nil

  
  init?(record: CKRecord, database: CKDatabase) {
    id = record.recordID
    let newName: String = record["name"] as? String ?? ""
    self.name = newName
    self.database = database
    //self.recipeURL = "https://www.mcdonalds.com/is/image/content/dam/uk/nfl/nutrition/nfl-product/product/products/mcdonalds-Big-Mac.jpg"
    self.recipeURL = GetImageLink(searchResult: newName)
    //self.description = record["description"] as? String ?? ""
    self.recipe_id = record["recipe_id"] as? Int64 ?? 0
    self.ingredients = record["ingredients"] as? [String] ?? [""]
    //self.minutes = record["minutes"] as? Int64 ?? 0
    self.steps = record["steps"] as? [String] ?? [""]
    //self.n_steps = Int64(steps.count)
  }
  
  func GetImageLink(searchResult: String) -> String{
    var returnStr: String = ""
    let url = URL(string: "https://grubgridimagesearch.herokuapp.com/grabimage/"+searchResult)
    guard let requestUrl = url else { fatalError() }
    // Create URL Request
    var request = URLRequest(url: requestUrl)
    // Specify HTTP Method to use
    request.httpMethod = "GET"
    // Send HTTP Request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        // Check if Error took place
        if let error = error {
            print("Error took place \(error)")
            return
        }
        // Read HTTP Response Status code
        if let response = response as? HTTPURLResponse {
            print("Response HTTP Status code: \(response.statusCode)")
        }
        // Convert HTTP Response Data to a simple String
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Response data string:\n \(dataString)")
          returnStr = dataString
        }
    }
    task.resume()
    return returnStr
  }
}

extension Recipe: Hashable {
  static func == (lhs: Recipe, rhs: Recipe) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  
}
