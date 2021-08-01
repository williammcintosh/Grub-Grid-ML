

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
    let nu_recipes: [Int] = [254921,361650,215716,248350]
    let nu_ratings: [Int] = [0,1,0,1]
    var sim_user_id: Int64 = 0
    if (nu_ratings.count % 2 == 0) && (nu_recipes.count % 2 == 0) {
      sim_user_id = GetCosineSimilarity(rec:nu_recipes,rat:nu_ratings)
    }
    
    // RETURNS NAME SEARCH:
    //let searchText = "arriba   baked winter squash mexican style"
    //let predicate = NSPredicate(format: "name == %@",searchText)
    
    // OR Predicate for the first word with 'OR' without the space:
    let searchTextA: [String] = [carbohydrate," "+carbohydrate,carbohydrate+"s",carbohydrate+"es"]
    let subPred1 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextA])
    
    // OR Predicate for the first word with 'OR' without the space:
    let searchTextB: [String] = [vegetable," "+vegetable,vegetable+"s",vegetable+"es"]
    let subPred2 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextB])
    
    // AND compound predicate combing both of the ones above:
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred1, subPred2])

    // I'm in the works of grabbing recipes from the same user_id, but having a challenging time doing so.
    //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "section", ascending: true),// sort by section key first
//                                     NSSortDescriptor(key:  "Name", ascending: true), //continue sorting by first name
//                                     NSSortDescriptor(key:  "LastName", ascending: true), //continue sorting by last name.
//                                     NSSortDescriptor(key: "Place", ascending: true)] //finally by place.
    let query = CKQuery(recordType: "Recipe", predicate: predicate)
    if (sim_user_id > 0) {
      let sim_user = NSSortDescriptor(key: "recipe_id", ascending: false)
      query.sortDescriptors = [sim_user]
    } else {
      let sort = NSSortDescriptor(key: "recipe_id", ascending: false)
      query.sortDescriptors = [sort]
    }
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
  
  func GetCosineSimilarity(rec: [Int], rat: [Int]) -> Int64{
    let recArray = (rec.map{String($0)}).joined(separator: ",")
    let ratArray = (rat.map{String($0)}).joined(separator: ",")
    var returnStr: Int64 = 0
    let url = URL(string: "https://grubgrid.herokuapp.com/cosine/"+recArray+","+ratArray)
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
          returnStr = Int64(dataString) ?? 0
        }
    }
    task.resume()
    return returnStr
  }
  
  public func printVegetable(){
    print(vegetable)
  }
}
