

import Foundation
import CloudKit

class Model {
  // MARK: - iCloud Info
  let container: CKContainer
  let publicDB: CKDatabase
  let privateDB: CKDatabase
  
  var carbohydrate = "rice"
  var vegetable = "tomatoes"
  
  var sim_user_id: Int64
  
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
    var queries = [CKQuery] ()
    
    print("****************************************************")
    print(nu_recipes)
    print("****************************************************")

    //var sim_user_id: Int64 = 0
    sim_user_id = GetCosineSimilarity(rec:nu_recipes,rat:nu_ratings)
    print("**********************************************************************")
    print(sim_user_id)
    print("***********************************************************************")
    
    // RETURNS NAME SEARCH:
    //let searchText = "arriba   baked winter squash mexican style"
    //let predicate = NSPredicate(format: "name == %@",searchText)
    
    if(sim_user_id != 0) {
      queries.append(GetRecipesWithLikedIds(user: sim_user_id))
    } else {
      queries.append(GetRecipes())
    }

    //SORTS LIST BY RECIPE_ID
    //let sort = NSSortDescriptor(key: "recipe_id", ascending: false)
    //query.sortDescriptors = [sort]
    AttachToMainThread(forQuery: queries, completion)
  }
  //Separating this into a different function is just for readability
  private func AttachToMainThread(forQuery queries: [CKQuery],
      _ completion: @escaping (Error?) -> Void) {
    for q in queries {
      publicDB.perform(q,inZoneWith: CKRecordZone.default().zoneID) { [weak self] results, error in
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
        //for r in self.recipes {
          //self.PrettyPrintRecipes(rName: r.name, rId: String(r.recipe_id), rIng: r.ingredients)
        //}
        DispatchQueue.main.async {
          completion(nil)
        }
      }
    }
  }
  
  func GetRecipesWithLikedIds(user: Int64) -> CKQuery {
    let searchTextA: [String] = [carbohydrate," "+carbohydrate,carbohydrate+"s",carbohydrate+"es"]
    let subPred1 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextA])
    // OR Predicate for the first word with 'OR' without the space:
    let searchTextB: [String] = [vegetable," "+vegetable,vegetable+"s",vegetable+"es"]
    let subPred2 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextB])
    // Attempting to prioritize recipe_id 13733
    //let priorityIds: [Int] = [13733,32441]
    //List of Id's that match user's interests
    let priorityIds: [Int] = GetSimUserRecipeIds(user: user)
    let subPred3 = NSPredicate (format: "recipe_id IN %@",argumentArray: [priorityIds])
    let subPred4 = NSPredicate (format: "NOT (recipe_id IN %@)", Model.currentModel.nu_recipes)
    //let subPred3 = NSPredicate (format: "NOT (recipe_id IN %@)", priorityIds)
    // AND compound predicate combing both of the ones above:
    let and_pred1 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred1, subPred2])
    let and_pred2 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred3, subPred4])
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [and_pred1, and_pred2])
    return CKQuery(recordType: "Recipe", predicate: predicate)
  }
  
  func GetSimUserRecipeIds(user: Int64) -> [Int] {
    let predicate = NSPredicate(format: "user_id == %@",user)
    let priorityArray = [Int](_immutableCocoaArray: CKQuery(recordType: "Ratings", predicate: predicate))
    print("%%%%%%%%%%%%%%%%%%%%%%%%")
    print("The array elements are \(priorityArray)")
    print("%%%%%%%%%%%%%%%%%%%%%%%%")
    //return CKQuery(recordType: "Ratings", predicate: predicate)
    return priorityArray
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
    var returnStr: Int64 = Model.currentModel.sim_user_id
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
            print("Response HTTP Status code for GetCosineSimilarity: \(response.statusCode)")
        }
        // Convert HTTP Response Data to a simple String
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
          print("Response data string for GetCosineSimilarity:\n \(dataString)")
          let convDataString: Int64? = Int64(dataString)
          returnStr = convDataString!
          Model.currentModel.sim_user_id = convDataString!
        }
    }
    task.resume()
    return returnStr
  }
  
  public func printVegetable(){
    print(vegetable)
  }
  
  func GetImageLink(searchResult: String) -> String{
    var returnStr: String = ""
    print("NAME = "+searchResult)
    print("https://grubgridimagesearch.herokuapp.com/grabimage/"+searchResult)
    let updatedStr = replaceSpacesWithWebSpaceFillers(searchResult: searchResult)
    let url = URL(string: "https://grubgridimagesearch.herokuapp.com/grabimage/\(updatedStr)")
    
    if url == nil {
      print("ITS NIL!")
    } else {
      print("IT WORKED!")
    }
    
    
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
            print("Response HTTP Status code for GetImageLink: \(response.statusCode)")
        }
        // Convert HTTP Response Data to a simple String
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Response data string for GetImageLink:\n \(dataString)")
          returnStr = dataString
        }
    }
    task.resume()
    return returnStr
  }
  
  func replaceSpacesWithWebSpaceFillers(searchResult: String) ->String{
    return searchResult.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
  }
  
  func GetRecipes() -> CKQuery {
    let searchTextA: [String] = [carbohydrate," "+carbohydrate,carbohydrate+"s",carbohydrate+"es"]
    let subPred1 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextA])
    // OR Predicate for the first word with 'OR' without the space:
    let searchTextB: [String] = [vegetable," "+vegetable,vegetable+"s",vegetable+"es"]
    let subPred2 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextB])
    // Attempting to prioritize recipe_id 13733
    //let priorityIds: [Int] = [13733,32441]
    // AND compound predicate combing both of the ones above:
    //let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred1, subPred2])
    let subPred3 = NSPredicate (format: "NOT (recipe_id IN %@)", Model.currentModel.nu_recipes)
    // AND compound predicate combing both of the ones above:
    let and_pred1 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred1, subPred2])
    let and_pred2 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred3])
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [and_pred1, and_pred2])
    return CKQuery(recordType: "Recipe", predicate: predicate)
  }
  
  /*
  func GetRecipesWithoutLikedIds(user: Int64) -> CKQuery {
    let searchTextA: [String] = [carbohydrate," "+carbohydrate,carbohydrate+"s",carbohydrate+"es"]
    let subPred1 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextA])
    // OR Predicate for the first word with 'OR' without the space:
    let searchTextB: [String] = [vegetable," "+vegetable,vegetable+"s",vegetable+"es"]
    let subPred2 = NSPredicate (format: "ANY ingredients IN %@",argumentArray: [searchTextB])
    // Attempting to prioritize recipe_id 13733
    //let priorityIds: [Int] = [13733,32441]
    let priorityIds: [Int] = GetSimUserRecipeIds(user: user)
   //let subPred3 = NSPredicate (format: "NOT (recipe_id IN %@)", priorityIds)
    let subPred3 = NSPredicate (format: "recipe_id IN %@",argumentArray: [priorityIds])
    // AND compound predicate combing both of the ones above:
    let and_pred1 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred1, subPred2])
    let and_pred2 = NSCompoundPredicate(andPredicateWithSubpredicates: [subPred3])
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [and_pred1, and_pred2])
    return CKQuery(recordType: "Recipe", predicate: predicate)
  }
 */
}
