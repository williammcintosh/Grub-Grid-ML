
import Foundation
import UIKit
import MapKit
import CloudKit
import CoreLocation

class Recipe {
  
  static let recordType = "Recipe"
  private let id: CKRecord.ID
  let database: CKDatabase
  var recipeURL: String
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
    var handlerUrl = "https://www.mcdonalds.com/is/image/content/dam/uk/nfl/nutrition/nfl-product/product/products/mcdonalds-Big-Mac.jpg"
    self.recipeURL = handlerUrl
    //self.description = record["description"] as? String ?? ""
    self.recipe_id = record["recipe_id"] as? Int64 ?? 0
    self.ingredients = record["ingredients"] as? [String] ?? [""]
    //self.minutes = record["minutes"] as? Int64 ?? 0
    self.steps = record["steps"] as? [String] ?? [""]
    //self.n_steps = Int64(steps.count)
    let semaphore = DispatchSemaphore(value: 0)  //1. create a counting semaphore
    Model.currentModel.GetImageLink(searchResult: self.name, urlCompletionHandler: { url, error in
      if let url = url {
        //print("the url is: \(url)")
        handlerUrl = url
        semaphore.signal()  //3. count it up
      }
    })
    //print("HANDLERURL:")
    //print(handlerUrl)
    semaphore.wait()  //2. wait for finished counting
    self.recipeURL = handlerUrl
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
