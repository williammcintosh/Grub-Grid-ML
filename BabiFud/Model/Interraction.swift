import Foundation
import UIKit
import MapKit
import CloudKit
import CoreLocation
 
class Interraction {
  
  static let recordType = "Interraction"
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
 
extension Interraction: Hashable {
  static func == (lhs: Interraction, rhs: Interraction) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
