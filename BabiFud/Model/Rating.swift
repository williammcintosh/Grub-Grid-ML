import Foundation
import UIKit
import MapKit
import CloudKit
import CoreLocation
 
class Rating {
  
  static let recordType = "Rating"
  private let id: CKRecord.ID
  let database: CKDatabase
  let user_id: Int64
  let recipe_id: Int64
  let freq: Int64
 
  init?(record: CKRecord, database: CKDatabase) {
    id = record.recordID
    self.user_id = record["user_id"] as? Int64 ?? 0
    self.database = database
    self.recipe_id = record["recipe_id"] as? Int64 ?? 0
    self.freq = record["freq"] as? Int64 ?? 0
  }
}
 
extension Rating: Hashable {
  static func == (lhs: Rating, rhs: Rating) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
