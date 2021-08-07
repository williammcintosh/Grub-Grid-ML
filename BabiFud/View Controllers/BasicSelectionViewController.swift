
import UIKit

class BasicSelectionViewController: UIViewController {
  @IBOutlet weak var findMeals: UIButton!
  
  @IBOutlet weak var pastaCover: UIView!
  @IBOutlet weak var beanCover: UIView!
  @IBOutlet weak var breadCover: UIView!
  @IBOutlet weak var oatCover: UIView!
  @IBOutlet weak var riceCover: UIView!
  @IBOutlet weak var potatoCover: UIView!
  
  @IBOutlet weak var cornCover: UIView!
  @IBOutlet weak var carrotCover: UIView!
  @IBOutlet weak var lettuceCover: UIView!
  @IBOutlet weak var tomatoCover: UIView!
  @IBOutlet weak var onionCover: UIView!
  @IBOutlet weak var cucumberCover: UIView!
  
  @IBOutlet weak var pastaOutlet: UIButton!
  @IBOutlet weak var beanOutlet: UIButton!
  @IBOutlet weak var breadOutlet: UIButton!
  @IBOutlet weak var oatOutlet: UIButton!
  @IBOutlet weak var riceOutlet: UIButton!
  @IBOutlet weak var potatoOutlet: UIButton!
  
  @IBOutlet weak var cornOutlet: UIButton!
  @IBOutlet weak var carrotOutlet: UIButton!
  @IBOutlet weak var lettuceOutlet: UIButton!
  @IBOutlet weak var tomatoOutlet: UIButton!
  @IBOutlet weak var onionOutlet: UIButton!
  @IBOutlet weak var cucumberOutlet: UIButton!
  
  //var model = Model()
  
  @IBAction func pastaButton(_ sender: Any) {
    pastaCover.isHidden = false;
    beanCover.isHidden = true;
    breadCover.isHidden = true;
    oatCover.isHidden = true;
    riceCover.isHidden = true;
    potatoCover.isHidden = true;
    
    Model.currentModel.carbohydrate = "noodles"
  }
  
  @IBAction func beanButton(_ sender: Any) {
    pastaCover.isHidden = true;
    beanCover.isHidden = false;
    breadCover.isHidden = true;
    oatCover.isHidden = true;
    riceCover.isHidden = true;
    potatoCover.isHidden = true;
    
    Model.currentModel.carbohydrate = "beans"
  }
  @IBAction func breadButton(_ sender: Any) {
    pastaCover.isHidden = true;
    beanCover.isHidden = true;
    breadCover.isHidden = false;
    oatCover.isHidden = true;
    riceCover.isHidden = true;
    potatoCover.isHidden = true;
    
    Model.currentModel.carbohydrate = "bread"
  }
  @IBAction func oatButton(_ sender: Any) {
    pastaCover.isHidden = true;
    beanCover.isHidden = true;
    breadCover.isHidden = true;
    oatCover.isHidden = false;
    riceCover.isHidden = true;
    potatoCover.isHidden = true;
    
    Model.currentModel.carbohydrate = "oats"
  }
  @IBAction func riceButton(_ sender: Any) {
    pastaCover.isHidden = true;
    beanCover.isHidden = true;
    breadCover.isHidden = true;
    oatCover.isHidden = true;
    riceCover.isHidden = false;
    potatoCover.isHidden = true;
    
    Model.currentModel.carbohydrate = "rice"
  }
  @IBAction func potatoButton(_ sender: Any) {
    pastaCover.isHidden = true;
    beanCover.isHidden = true;
    breadCover.isHidden = true;
    oatCover.isHidden = true;
    riceCover.isHidden = true;
    potatoCover.isHidden = false;
    
    Model.currentModel.carbohydrate = "potato"
  }
  
  @IBAction func cornButton(_ sender: Any) {
    cornCover.isHidden = false;
    carrotCover.isHidden = true;
    lettuceCover.isHidden = true;
    tomatoCover.isHidden = true;
    onionCover.isHidden = true;
    cucumberCover.isHidden = true;
    
    Model.currentModel.vegetable = "corn"
  }
  @IBAction func carrotButton(_ sender: Any) {
    cornCover.isHidden = true;
    carrotCover.isHidden = false;
    lettuceCover.isHidden = true;
    tomatoCover.isHidden = true;
    onionCover.isHidden = true;
    cucumberCover.isHidden = true;
    
    Model.currentModel.vegetable = "carrot"
  }
  @IBAction func lettuceButton(_ sender: Any) {
    cornCover.isHidden = true;
    carrotCover.isHidden = true;
    lettuceCover.isHidden = false;
    tomatoCover.isHidden = true;
    onionCover.isHidden = true;
    cucumberCover.isHidden = true;
    
    Model.currentModel.vegetable = "lettuce"
  }
  @IBAction func tomatoButton(_ sender: Any) {
    cornCover.isHidden = true;
    carrotCover.isHidden = true;
    lettuceCover.isHidden = true;
    tomatoCover.isHidden = false;
    onionCover.isHidden = true;
    cucumberCover.isHidden = true;
    
    Model.currentModel.vegetable = "tomato"
  }
  @IBAction func onionButton(_ sender: Any) {
    cornCover.isHidden = true;
    carrotCover.isHidden = true;
    lettuceCover.isHidden = true;
    tomatoCover.isHidden = true;
    onionCover.isHidden = false;
    cucumberCover.isHidden = true;
    
    Model.currentModel.vegetable = "onion"
  }
  @IBAction func cucumberButton(_ sender: Any) {
    cornCover.isHidden = true;
    carrotCover.isHidden = true;
    lettuceCover.isHidden = true;
    tomatoCover.isHidden = true;
    onionCover.isHidden = true;
    cucumberCover.isHidden = false;
    
    Model.currentModel.vegetable = "cucumber"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pastaCover.layer.cornerRadius = 55
    pastaCover.clipsToBounds = true
    pastaCover.isHidden = true;
    beanCover.layer.cornerRadius = 55
    beanCover.clipsToBounds = true
    beanCover.isHidden = true;
    breadCover.layer.cornerRadius = 55
    breadCover.clipsToBounds = true
    breadCover.isHidden = true;
    oatCover.layer.cornerRadius = 55
    oatCover.clipsToBounds = true
    oatCover.isHidden = true;
    riceCover.layer.cornerRadius = 55
    riceCover.clipsToBounds = true
    riceCover.isHidden = true;
    potatoCover.layer.cornerRadius = 55
    potatoCover.clipsToBounds = true
    potatoCover.isHidden = true;
    cornCover.layer.cornerRadius = 55
    cornCover.clipsToBounds = true
    cornCover.isHidden = true;
    carrotCover.layer.cornerRadius = 55
    carrotCover.clipsToBounds = true
    carrotCover.isHidden = true;
    lettuceCover.layer.cornerRadius = 55
    lettuceCover.clipsToBounds = true
    lettuceCover.isHidden = true;
    tomatoCover.layer.cornerRadius = 55
    tomatoCover.clipsToBounds = true
    tomatoCover.isHidden = true;
    onionCover.layer.cornerRadius = 55
    onionCover.clipsToBounds = true
    onionCover.isHidden = true;
    cucumberCover.layer.cornerRadius = 55
    cucumberCover.clipsToBounds = true
    cucumberCover.isHidden = true;
    pastaOutlet.layer.cornerRadius = 55
    pastaOutlet.clipsToBounds = true
    beanOutlet.layer.cornerRadius = 55
    beanOutlet.clipsToBounds = true
    breadOutlet.layer.cornerRadius = 55
    breadOutlet.clipsToBounds = true
    oatOutlet.layer.cornerRadius = 55
    oatOutlet.clipsToBounds = true
    riceOutlet.layer.cornerRadius = 55
    riceOutlet.clipsToBounds = true
    potatoOutlet.layer.cornerRadius = 55
    potatoOutlet.clipsToBounds = true
    cornOutlet.layer.cornerRadius = 55
    cornOutlet.clipsToBounds = true
    carrotOutlet.layer.cornerRadius = 55
    carrotOutlet.clipsToBounds = true
    lettuceOutlet.layer.cornerRadius = 55
    lettuceOutlet.clipsToBounds = true
    tomatoOutlet.layer.cornerRadius = 55
    tomatoOutlet.clipsToBounds = true
    onionOutlet.layer.cornerRadius = 55
    onionOutlet.clipsToBounds = true
    cucumberOutlet.layer.cornerRadius = 55
    cucumberOutlet.clipsToBounds = true
    findMeals.layer.cornerRadius = 10
    findMeals.clipsToBounds = true
  }
}
