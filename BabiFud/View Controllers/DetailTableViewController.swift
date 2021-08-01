import UIKit
import CloudKit
//import TabularData
//import CreateML

class DetailTableViewController: UITableViewController {
  // MARK: - Outlets
  //@IBOutlet weak var CTLabel: UILabel!
  
  @IBOutlet weak var re_text: UITextView!
  @IBOutlet weak var removeOutlet: UIButton!
  @IBOutlet weak var addOutlet: UIButton!
  
  
  @IBAction func removeButton(_ sender: Any) {
  }
  @IBAction func addButton(_ sender: Any) {
  }
  
  // MARK: - Properties
  var recipe: Recipe?
  
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
  
  @IBAction func WritingToCKRecord(_ sender: UIButton) {
    print("Submission Sent")
    loadRatingCSV(from: "0-400000_cleanedup_RAW_interactions")
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
    //title = recipe.name
    re_text.text = "Name:\n" + recipe.name + "\n\nIngredients:\n"
    for s in 0..<recipe.ingredients.count {
      re_text.text = re_text.text! + String(s+1) + ": " + recipe.ingredients[s] + "\n"
    }

    re_text.text = re_text.text! + "\nSteps:"
    for s in 0..<recipe.steps.count {
      re_text.text = re_text.text! + "\t"+String(s+1)+": "+recipe.steps[s] + "\n"
    }
  }
  
  // MARK: - Navigation
  @IBSegueAction private func notesSegue(coder: NSCoder, sender: Any?) -> NotesTableViewController? {
    guard let notesTableViewController = NotesTableViewController(coder: coder) else { return nil }
    notesTableViewController.recipe = recipe

    return notesTableViewController
  }
}
