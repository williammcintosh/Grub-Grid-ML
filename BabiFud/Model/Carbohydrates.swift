import Foundation
import UIKit

class Carbohydrates {
  //MARK: - Public API
  var name = ""
  var image: UIImage
  
  init(name: String, image: UIImage) {
    self.name = name
    self.image = image
  }
  
  //MARK: -Private
  static func fetchCarbohydrates() -> [Carbohydrates] {
    return [
      Carbohydrates(name: "rice", image: UIImage(named: "riceImage")!),
      Carbohydrates(name: "beans", image: UIImage(named: "beansImage")!),
      Carbohydrates(name: "bread", image: UIImage(named: "breadImage")!),
      Carbohydrates(name: "pasta", image: UIImage(named: "pastaImage")!),
      Carbohydrates(name: "potatoes", image: UIImage(named: "potatoesImage")!)
    ]
  }
  
}
