import UIKit

class SelectionViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  var carbohydrates = Carbohydrates.fetchCarbohydrates()
  let cellScale: CGFloat = 0.6
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //let screenSize = UIScreen.main.bounds.size
    //let cellWidth = floor(screenSize.width * cellScale)
    //let cellHeight = floor(screenSize.height * cellScale)
    //let insetX = (view.bounds.width - cellWidth) / 2.0
    //let insetY = (view.bounds.height - cellHeight) / 2.0
    
    //let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
    
    collectionView.dataSource = self
  }
}

// MARK: - UICollectionViewDataSource

extension SelectionViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return carbohydrates.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarbohydratesCollectionViewCell", for: indexPath) as! CarbohydratesCollectionViewCell
    let carbs = carbohydrates[indexPath.item]
    
    cell.carbohydrates = carbs
    
    return cell
  }
}
