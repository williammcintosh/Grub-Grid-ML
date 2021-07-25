import UIKit
import CloudKit
//import TabularData
//import CreateML

class DetailTableViewController: UITableViewController {
  // MARK: - Outlets
  //@IBOutlet weak var CTLabel: UILabel!
  
  @IBOutlet weak var re_text: UITextView!
  // MARK: - Properties
  var recipe: Recipe?
  
  func PrettyPrintRecipes(recipe: RecipeObj) {
    //"","name","id","minutes","nutrition","n_steps","steps","description","ingredients","n_ingredients"
    //"4","amish  tomato ketchup  for canning","44061","190","[352.9, 1.0, 337.0, 23.0, 3.0, 0.0, 28.0]"
    print("Index: "+String(recipe.index))
    print("Name: "+recipe.name)
    print("Recipe_id: "+String(recipe.recipe_id))
    print("Minutes: "+String(recipe.minutes))
    print("Nutrition:")
    print("\t Calories: "+String(recipe.nutrition[0]))
    print("\t Total Fat g: "+String(recipe.nutrition[1]))
    print("\t %Daily Sugar : "+String(recipe.nutrition[2]))
    print("\t %Daily Sodium: "+String(recipe.nutrition[3]))
    print("\t %Daily Fiber: "+String(recipe.nutrition[4]))
    print("\t Cholesterol: "+String(recipe.nutrition[5]))
    print("\t %Daily Carbohydrate: "+String(recipe.nutrition[6]))
    print("Number of Steps: "+String(recipe.n_steps))
    print("Steps:")
    for s in 0..<recipe.steps.count {
      print("\t"+String(s)+": "+recipe.steps[s])
    }
    print("Description: "+recipe.description)
    print("Number of Ingredients: "+String(recipe.n_ingredients))
    print("Ingredients:")
    for s in 0..<recipe.ingredients.count {
      print("\t"+String(s)+": "+recipe.ingredients[s])
    }
  }
 
  
  @IBAction func WritingToCKRecord(_ sender: UIButton) {
    print("Submission Sent")
    let recipes = loadRecipeCSV(from: "1000000_cleanedup_RAW_recipes")
    PrettyPrintRecipes(recipe: recipes[0])
    for i in 0..<recipes.count {
      UploadRecipeToCKRecord(recipe: recipes[i], count: String(i))
    }
  }
  
  func UploadRecipeToCKRecord(recipe: RecipeObj, count: String) {
    //"","name","id","minutes","nutrition","n_steps","steps","description","ingredients","n_ingredients"
    let itemRecord = CKRecord(recordType: "Recipe")
    itemRecord["index"] = recipe.index as CKRecordValue
    itemRecord["name"] = recipe.name as CKRecordValue
    itemRecord["recipe_id"] = recipe.recipe_id as CKRecordValue
    itemRecord["minutes"] = recipe.minutes as CKRecordValue
    itemRecord["n_steps"] = recipe.n_steps as CKRecordValue
    itemRecord["steps"] = recipe.steps as CKRecordValue
    itemRecord["description"] = recipe.description as CKRecordValue
    itemRecord["ingredients"] = recipe.ingredients as CKRecordValue
    itemRecord["n_ingredients"] = recipe.n_ingredients as CKRecordValue
    itemRecord["nutrition"] = recipe.nutrition as CKRecordValue

    CKContainer.default().publicCloudDatabase.save(itemRecord) { (record, error) in
      DispatchQueue.main.async {
        if error == nil {
          print("Saving number "+count+" recipe_id: "+String(recipe.n_steps))
            self.tableView.reloadData()
        } else {
          let ac = UIAlertController(title: "Error", message: "There was a problem submitting your suggestion: \(error!.localizedDescription)", preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(ac, animated: true)
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func PrettyPrintRecipes() {
    
  }
  
  private func setup() {
    guard let recipe = recipe else { return }
    //title = recipe.name
    re_text.text = "Name:\n" + recipe.name + "\n\nIngredients:\n"
    for s in 0..<recipe.ingredients.count {
      re_text.text = re_text.text! + String(s+1) + ": " + recipe.ingredients[s] + "\n"
    }
    re_text.text = re_text.text! + "Minutes:\n" + String(recipe.minutes)
/*
    re_text.text = re_text.text! + "\n\nNutrition:\n"
    re_text.text = re_text.text! + "\tCalories: " + String(recipe.nutrition[0])+"\n"
    re_text.text = re_text.text! + "\tTotal Fat " + String(recipe.nutrition[1])+"\n"
    re_text.text = re_text.text! + "\t %Daily Sugar : " + String(recipe.nutrition[2])+"\n"
    re_text.text = re_text.text! + "\t %Daily Sodium: " + String(recipe.nutrition[3])+"\n"
    re_text.text = re_text.text! + "\t %Daily Fiber: " + String(recipe.nutrition[4])+"\n"
    re_text.text = re_text.text! + "\t Cholesterol: " + String(recipe.nutrition[5])+"\n"
    re_text.text = re_text.text! + "\t %Daily Carbohydrate: " + String(recipe.nutrition[6])+"\n"
*/
    re_text.text = re_text.text! + "\nNumber of Steps: " + String(recipe.n_steps) + "\n"
    re_text.text = re_text.text! + "\nSteps:"
    for s in 0..<recipe.steps.count {
      re_text.text = re_text.text! + "\t"+String(s+1)+": "+recipe.steps[s] + "\n"
    }
    re_text.text = re_text.text! + "\nDescription: "+recipe.description + "\n"
  }
  
  // MARK: - Navigation
  @IBSegueAction private func notesSegue(coder: NSCoder, sender: Any?) -> NotesTableViewController? {
    guard let notesTableViewController = NotesTableViewController(coder: coder) else { return nil }
    notesTableViewController.recipe = recipe

    return notesTableViewController
  }
}
