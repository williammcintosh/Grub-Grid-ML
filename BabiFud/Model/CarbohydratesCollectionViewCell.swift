import UIKit

class CarbohydratesCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  //@IBOutlet weak var carbohydrateView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  
  var carbohydrates: Carbohydrates! {
    didSet {
      self.updateUI()
    }
  }
  func updateUI() {
    if let carbohydrates = carbohydrates {
      imageView.image = carbohydrates.image
      nameLabel.text = carbohydrates.name
    } else {
      imageView.image = nil
      nameLabel.text = nil
    }
    
    //carbohydrateView.layer.cornerRadius = 10.0
    //carbohydrateView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 10.0
    imageView.layer.masksToBounds = true
  }
}
