

import Foundation
import CloudKit

class Model {
  // MARK: - iCloud Info
  let container: CKContainer
  let publicDB: CKDatabase
  let privateDB: CKDatabase
  
  // MARK: - Properties
  //private(set) var establishments: [Establishment] = []
  private(set) var recipes: [Recipe] = []

  static var currentModel = Model()
  
  init() {
    container = CKContainer.default()
    publicDB = container.publicCloudDatabase
    privateDB = container.privateCloudDatabase
  }
  
  @objc func refresh(_ completion: @escaping (Error?) -> Void) {
    
    // RETURNS ALL RECIPES:
    //let predicate = NSPredicate(value: true)
    
    // RETURNS NAME SEARCH:
    //let searchText = "arriba   baked winter squash mexican style"
    //let predicate = NSPredicate(format: "name == %@",searchText)
   
    // RETURNS INGREDIENTS WITH BUTTER
    //let searchText = "butter"
    //let predicate = NSPredicate(format: "ANY ingredients == %@",searchText)
    
    // RETURNS INGREDIENTS WITH KEYWORD:
    let searchText: [String] = ["butter","Butter","french bread"]
    let predicate = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchText])
    
    //ANY ingredients in the array, but both searchText[] values need to match

    
    let sort = NSSortDescriptor(key: "recipe_id", ascending: false)
    let query = CKQuery(recordType: "Recipe", predicate: predicate)
    query.sortDescriptors = [sort]
    AttachToMainThread(forQuery: query, completion)
  }
  //Separating this into a different function isn't necessary
  private func AttachToMainThread(forQuery query: CKQuery,
      _ completion: @escaping (Error?) -> Void) {
    publicDB.perform(query,
        inZoneWith: CKRecordZone.default().zoneID) { [weak self] results, error in
      guard let self = self else { return }
      if let error = error {
        DispatchQueue.main.async {
          completion(error)
        }
        return
      }
      guard let results = results else { return }
      self.recipes = results.compactMap {
        Recipe(record: $0, database: self.publicDB)
      }
      DispatchQueue.main.async {
        completion(nil)
      }
    }
  }
}
