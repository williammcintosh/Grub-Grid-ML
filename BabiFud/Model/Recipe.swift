
import Foundation
import UIKit
import MapKit
import CloudKit
import CoreLocation

class Recipe {
  
  static let recordType = "Recipe"
  private let id: CKRecord.ID
  let database: CKDatabase
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
    self.name = record["name"] as? String ?? ""
    self.database = database
    //self.description = record["description"] as? String ?? ""
    self.recipe_id = record["recipe_id"] as? Int64 ?? 0
    self.ingredients = record["ingredients"] as? [String] ?? [""]
    //self.minutes = record["minutes"] as? Int64 ?? 0
    self.steps = record["steps"] as? [String] ?? [""]
    //self.n_steps = Int64(steps.count)
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
