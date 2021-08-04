

import Foundation
import CloudKit

class Model {
  // MARK: - iCloud Info
  let container: CKContainer
  let publicDB: CKDatabase
  let privateDB: CKDatabase
  
  var carbohydrate = "rice"
  var vegetable = "tomatoes"
  
  var sim_user_id: Int = 0
  
  var nu_recipes: [Int] = [254921,361650,215716,248350]
  var nu_ratings: [Int] = [0,1,0,1]
  
  // MARK: - Properties
  private(set) var recipes: [Recipe] = []

  static var currentModel = Model()
  
  init() {
    container = CKContainer.default()
    publicDB = container.publicCloudDatabase
    privateDB = container.privateCloudDatabase
    sim_user_id = 0;
  }
  
  @objc func refresh(_ completion: @escaping (Error?) -> Void) {
    print("----------Refresh is getting called------------")
    var query: CKQuery
    GetSimUserID(rec:nu_recipes,rat:nu_ratings)
    if(sim_user_id != 0) {
      query = GetRecipesWithSimUserLikedIds(user: sim_user_id)
    } else {
      query = GetRecipes()
    }
    let sort = NSSortDescriptor(key: "recipe_id", ascending: false)
    query.sortDescriptors = [sort]
    
    let operation = CKQueryOperation (query: query)
  
    AttachToMainThread(forQuery: operation, completion)
    //AttachToMainThread(forQuery: query, completion)
  }
  
  private func AttachToMainThread(forQuery operation: CKQueryOperation,
    _ completion: @escaping (Error?) -> Void) {
    operation.resultsLimit = 10
    var newItems = [Recipe]()
    operation.queryCompletionBlock = ( { (cursor, error)->Void in
        guard error == nil else {
            DispatchQueue.main.async {
              completion(error)
              print("Cloud Query Error - Refresh: \(String(describing: error))")
            }
            return
        }
        self.recipes = newItems
        DispatchQueue.main.async {
          completion(nil)
        }
    })
    operation.recordFetchedBlock = ( { (record) -> Void in
      let newrecipe = Recipe(record: record, database: self.publicDB)
      newItems.append(newrecipe!)
    })
    for r in self.recipes {
      self.PrettyPrintRecipes(rName: r.name, rId: String(r.recipe_id), rIng: r.ingredients)
    }
    publicDB.add(operation)
  }
  //Separating this into a different function is just for readability
  private func AttachToMainThread(forQuery query: CKQuery,
    _ completion: @escaping (Error?) -> Void) {
    publicDB.perform(query,inZoneWith: CKRecordZone.default().zoneID) { [weak self] results, error in
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
  
  func GetRecipesWithSimUserLikedIds(user: Int) -> CKQuery {
    let subPred1 = GetCarbPred()
    let subPred2 = GetVeggiePred()
    let priorityIds: [Int] = GetSimUserLikedRecipeIds(user: user)
    let subPred3 = NSPredicate (format: "recipe_id IN %@",argumentArray: [priorityIds])
    let subPred4 = NSPredicate (format: "NOT (recipe_id IN %@)", Model.currentModel.nu_recipes)
    let predicate = CombinePredicates(subPred1: subPred1, subPred2: subPred2, subPred3: subPred3, subPred4: subPred4)
    return CKQuery(recordType: "Recipe", predicate: predicate)
  }
  
  func GetSimUserLikedRecipeIds(user: Int) -> [Int] {
    let predicate = NSPredicate(format: "user_id == %@",NSNumber(value: user))
    let query = CKQuery(recordType: "Ratings", predicate: predicate)
    print(query)
    //Ids that have tomatoes and rice
    var priorityList: [Int] = [352320, 75663, 144593, 370310]
    let operation = CKQueryOperation(query: query)
    operation.desiredKeys = ["recipe_id"]
    //operation.resultsLimit = 50
    print("STUFF BELOW NEVER PRINTS.")
    print("THE GOAL IS TO GAIN ACCESS TO THE RECIPE_IDs FROM THE QUERY ABOVE.")
    operation.recordFetchedBlock = { record in
      let recipe = Recipe(record: record,database: self.publicDB)
      print("RECIPE INFO")
      print(recipe?.recipe_id)
      //Appends onto the list of int but I get an error with the code below
      //priorityList.append(Int(recipe.recipe_id))
    }
    return priorityList
  }
  

  func PrettyPrintRecipes(rName: String, rId: String, rIng: [String]) {
    print("Name: "+rName)
    print("Recipe_id: "+rId)
    print("Ingredients:")
    for s in 0..<rIng.count {
      print("\t"+String(s)+": "+rIng[s])
    }
  }
  
  func GetSimUserID(rec: [Int], rat: [Int]) {
    let recArray = (rec.map{String($0)}).joined(separator: ",")
    let ratArray = (rat.map{String($0)}).joined(separator: ",")
    var returnStr: Int = Model.currentModel.sim_user_id
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
        //if let response = response as? HTTPURLResponse {
            //print("Response HTTP Status code for GetSimUserID: \(response.statusCode)")
        //}
        // Convert HTTP Response Data to a simple String
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
          //print("Response data string for GetSimUserID:\n \(dataString)")
          let convDataString: Int? = Int(dataString)
          //returnStr = convDataString!
          Model.currentModel.sim_user_id = convDataString!
        }
    }
    task.resume()
    //return returnStr
  }
  
  public func printVegetable(){
    print(vegetable)
  }
  
  func GetImageLink(searchResult: String, urlCompletionHandler: @escaping (String?, Error?) -> Void) {
    let updatedStr = replaceSpacesWithWebSpaceFillers(searchResult: searchResult)
    let url = URL(string: "https://grubgridimagesearch.herokuapp.com/grabimage/\(updatedStr)")
    guard let requestUrl = url else { fatalError() }
    // Create URL Request
    var request = URLRequest(url: requestUrl)
    // Specify HTTP Method to use
    request.httpMethod = "GET"
    // Send HTTP Request
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
      // Check if Error took place
        if let error = error {
            print("Error took place \(error)")
            return
        }
        // Read HTTP Response Status code
        if let response = response as? HTTPURLResponse {
            print("Response HTTP Status code for GetImageLink: \(response.statusCode)")
        }
        // Convert HTTP Response Data to a simple String
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Response data string for GetImageLink:\n \(dataString)")
            urlCompletionHandler(dataString, nil)
        }
      })
      task.resume()
      return
  }
  
  func replaceSpacesWithWebSpaceFillers(searchResult: String) ->String{
    return searchResult.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
  }
  
  func GetRecipes() -> CKQuery {
    let subPred1 = GetCarbPred()
    let subPred2 = GetVeggiePred()
    let subPred3 = NSPredicate (format: "NOT (recipe_id IN %@)", Model.currentModel.nu_recipes)
    let predicate = CombinePredicates(subPred1: subPred1, subPred2: subPred2, subPred3: subPred3)
    return CKQuery(recordType: "Recipe", predicate: predicate)
  }
  
  func GetCarbPred() -> NSPredicate {
    let searchTextA: [String] = [carbohydrate," "+carbohydrate,carbohydrate+"s",carbohydrate+"es"]
    return NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextA])
  }
  
  func GetVeggiePred() -> NSPredicate {
    let searchTextB: [String] = [vegetable," "+vegetable,vegetable+"s",vegetable+"es"]
    return NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextB])
  }
  
  func CombinePredicates(subPred1: NSPredicate, subPred2: NSPredicate, subPred3: NSPredicate) -> NSCompoundPredicate {
    let and_pred1 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred1, subPred2])
    let and_pred2 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred3])
    return NSCompoundPredicate(andPredicateWithSubpredicates: [and_pred1, and_pred2])
  }
  func CombinePredicates(subPred1: NSPredicate, subPred2: NSPredicate, subPred3: NSPredicate, subPred4: NSPredicate) -> NSCompoundPredicate {
    let and_pred1 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred1, subPred2])
    let and_pred2 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred3, subPred4])
    return NSCompoundPredicate(andPredicateWithSubpredicates: [and_pred1, and_pred2])
  }

}
