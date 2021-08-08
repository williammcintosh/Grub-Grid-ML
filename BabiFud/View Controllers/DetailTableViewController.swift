import UIKit
import CloudKit
//import TabularData
//import CreateML

class DetailTableViewController: UITableViewController {
  
  var recipe: Recipe?
  
  // MARK: - Outlets
  //@IBOutlet weak var CTLabel: UILabel!
  
  @IBOutlet weak var ingredientsTextScrollView: UITextView!
  @IBOutlet weak var stepsTextScrollView: UITextView!
  @IBOutlet weak var removeOutlet: UIButton!
  @IBOutlet weak var addOutlet: UIButton!
  @IBOutlet weak var recipeImageView: UIImageView!
  @IBOutlet weak var recipeNameLabel: UILabel!
  
  
  @IBAction func removeButton(_ sender: Any) {
    guard let recipe = recipe else { return }
    if Model.currentModel.nu_recipes.contains(Int(recipe.recipe_id)) == false {
      Model.currentModel.nu_recipes.append(Int(recipe.recipe_id))
      Model.currentModel.nu_ratings.append(0)
      print("SIZE OF NU_RECIPE LIST: "+String(Model.currentModel.nu_recipes.count))

      for i in 0 ..< Model.currentModel.nu_recipes.count {
        let r_id = Model.currentModel.nu_recipes[i]
        let r_ra = Model.currentModel.nu_ratings[i]
        print(String(r_id)+" "+String(r_ra))
      }
    }
  }
  @IBAction func addButton(_ sender: Any) {
    guard let recipe = recipe else { return }
    if Model.currentModel.nu_recipes.contains(Int(recipe.recipe_id)) == false {
      Model.currentModel.nu_recipes.append(Int(recipe.recipe_id))
      Model.currentModel.nu_ratings.append(1)
      print("SIZE OF NU_RECIPE LIST: "+String(Model.currentModel.nu_recipes.count))
      
      for i in 0 ..< Model.currentModel.nu_recipes.count {
        let r_id = Model.currentModel.nu_recipes[i]
        let r_ra = Model.currentModel.nu_ratings[i]
        print(String(r_id)+" "+String(r_ra))
      }
    }
  }
  
  // MARK: - Properties
  func PrettyPrintRecipes(recipe: RecipeObj) {
    print("Name: "+recipe.name)
    print("Recipe_id: "+String(recipe.recipe_id))
    //print("Steps:")
    //for s in 0..<recipe.steps.count {
    //  print("\t"+String(s)+": "+recipe.steps[s])
    //}
    print("Ingredients:")
    for s in 0..<recipe.ingredients.count {
      print("\t"+String(s)+": "+recipe.ingredients[s])
    }
  }

  func UploadRecipeToCKRecord(recipe: RecipeObj, count: String) {
    let itemRecord = CKRecord(recordType: "Recipe")
    itemRecord["name"] = recipe.name as CKRecordValue
    itemRecord["recipe_id"] = recipe.recipe_id as CKRecordValue
    itemRecord["steps"] = recipe.steps as CKRecordValue
    itemRecord["ingredients"] = recipe.ingredients as CKRecordValue

    CKContainer.default().publicCloudDatabase.save(itemRecord) { (record, error) in
      DispatchQueue.main.async {
        if error == nil {
          print("Saving number "+count+" recipe_id: "+String(recipe.recipe_id))
            self.tableView.reloadData()
        } else {
          let ac = UIAlertController(title: "Error", message: "There was a problem submitting your suggestion: \(error!.localizedDescription)", preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(ac, animated: true)
        }
      }
    }
  }
  func UploadRatingToCKRecord(myRat: RatingObj, count: String) {
    let itemRecord = CKRecord(recordType: "Ratings")
    itemRecord["user_id"] = myRat.user_id as CKRecordValue
    itemRecord["recipe_id"] = myRat.recipe_id as CKRecordValue
    itemRecord["rating"] = myRat.rating as CKRecordValue
    itemRecord["freq"] = myRat.freq as CKRecordValue

    CKContainer.default().publicCloudDatabase.save(itemRecord) { (record, error) in
      DispatchQueue.main.async {
        if error == nil {
          print("Saving number "+count+" user_id: "+String(myRat.user_id))
            self.tableView.reloadData()
        } else {
          let ac = UIAlertController(title: "Error", message: "There was a problem submitting your suggestion: \(error!.localizedDescription)", preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(ac, animated: true)
        }
      }
    }
  }
  func UploadInterractionToCKRecord(myRat: InterractionObj, count: String) {
    let itemRecord = CKRecord(recordType: "Interraction")
    itemRecord["user_id"] = myRat.user_id as CKRecordValue
    itemRecord["recipe_id"] = myRat.recipe_id as CKRecordValue
    itemRecord["rating"] = myRat.rating as CKRecordValue
    itemRecord["freq"] = myRat.freq as CKRecordValue

    CKContainer.default().publicCloudDatabase.save(itemRecord) { (record, error) in
      DispatchQueue.main.async {
        if error == nil {
          print("Saving number "+count+" user_id: "+String(myRat.user_id))
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
    removeOutlet.layer.cornerRadius = 10
    removeOutlet.clipsToBounds = true
    addOutlet.layer.cornerRadius = 10
    addOutlet.clipsToBounds = true
    setup()
  }
  
  private func setup() {
    guard let recipe = recipe else { return }
    
    Model.currentModel.UpdateImage(recipe: recipe)
    recipeImageView.downloaded(from: recipe.recipeURL)
    recipeImageView.layer.cornerRadius = 15
    recipeImageView.clipsToBounds = true
    //title = recipe.name
    recipeNameLabel.text = recipe.name
    for s in 0..<recipe.ingredients.count {
      ingredientsTextScrollView.text = ingredientsTextScrollView.text! + "\t\t" + String(s+1) + ": " + recipe.ingredients[s] + "\n"
    }
    for s in 0..<recipe.steps.count {
      stepsTextScrollView.text = stepsTextScrollView.text! + "\t\t"+String(s+1)+": "+recipe.steps[s] + "\n"
    }
  }
  
  // MARK: - Navigation
  @IBSegueAction private func notesSegue(coder: NSCoder, sender: Any?) -> NotesTableViewController? {
    guard let notesTableViewController = NotesTableViewController(coder: coder) else { return nil }
    notesTableViewController.recipe = recipe

    return notesTableViewController
  }
}
