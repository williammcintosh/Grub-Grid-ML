

import Foundation
import CloudKit

class Model {
  // MARK: - iCloud Info
  let container: CKContainer
  let publicDB: CKDatabase
  let privateDB: CKDatabase
  
  var carbohydrate = "rice"
  var vegetable = "tomatoes"
  
  // MARK: - Properties
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
   
    // RETURNS INGREDIENTS WITH BUTTER (SINGLE):
    //let predicate = NSPredicate(format: "ingredients CONTAINS %@","butter")
    //let predicate = NSPredicate(format: "ingredients CONTAINS %@"," butter")
    
    // OR Predicate for the first word with 'OR' without the space:
    let searchTextA: [String] = [carbohydrate," "+carbohydrate,carbohydrate+"s",carbohydrate+"es"]
    let subPred1 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextA])
    
    // OR Predicate for the first word with 'OR' without the space:
    let searchTextB: [String] = [vegetable," "+vegetable,vegetable+"s",vegetable+"es"]
    let subPred2 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextB])
    
    // AND compound predicate combing both of the ones above:
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred1, subPred2])

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
      for r in self.recipes {
        self.PrettyPrintRecipes(rName: r.name, rId: String(r.recipe_id), rIng: r.ingredients)
      }
      DispatchQueue.main.async {
        completion(nil)
      }
    }
  }

  func PrettyPrintRecipes(rName: String, rId: String, rIng: [String]) {
    print("Name: "+rName)
    print("Recipe_id: "+rId)
    print("Ingredients:")
    for s in 0..<rIng.count {
      print("\t"+String(s)+": "+rIng[s])
    }
}
  
  public func printVegetable(){
    print(vegetable)
  }
}
