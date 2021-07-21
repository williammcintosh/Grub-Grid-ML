import UIKit
import CoreLocation

class NearbyTableViewController: UITableViewController {
  var locationManager: CLLocationManager!
  //var dataSource: UITableViewDiffableDataSource<Int, Establishment>?
  var dataSource: UITableViewDiffableDataSource<Int, Recipe>?

  override func viewDidLoad() {
    super.viewDidLoad()
    //setupLocationManager()
    //dataSource = establishmentDataSource()
    dataSource = recipeDataSource()
    tableView.dataSource = dataSource
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    refresh()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    reloadSnapshot(animated: false)
  }
  
  @objc private func refresh() {
    Model.currentModel.refresh { error in
      if let error = error {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.tableView.refreshControl?.endRefreshing()
        return
      }
      self.tableView.refreshControl?.endRefreshing()
      self.reloadSnapshot(animated: true)
    }
  }

  // MARK: - Navigation
  @IBSegueAction private func detailSegue(coder: NSCoder, sender: Any?) -> DetailTableViewController? {
    guard
      let cell = sender as? NearbyCell,
      let indexPath = tableView.indexPath(for: cell),
      let detailViewController = DetailTableViewController(coder: coder)
      else { return nil }
    detailViewController.recipe = Model.currentModel.recipes[indexPath.row]

    return detailViewController
  }
}

extension NearbyTableViewController {
  private func recipeDataSource() -> UITableViewDiffableDataSource<Int, Recipe> {
    return UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, recipe) -> NearbyCell? in
      let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyCell", for: indexPath) as? NearbyCell
      //for i in 0..<recipe.ingredients.count {
        //if recipe.ingredients[i].uppercased().contains("BUTTER") {
          cell?.recipe = recipe
        //}
      //}
      return cell
    }
  }
  
  private func reloadSnapshot(animated: Bool) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, Recipe>()
    /*
    var recipesToKeep: [Recipe] = []
    let currentRecipes = Model.currentModel.recipes
    for i in 0..<currentRecipes.count {
      for j in 0..<currentRecipes[i].ingredients.count {
        if currentRecipes[i].ingredients[j].uppercased().contains("BUTTER") {
          recipesToKeep.append(currentRecipes[i])
        }
      }
    }
    snapshot.appendItems(recipesToKeep)
    */
    snapshot.appendSections([0])
    snapshot.appendItems(Model.currentModel.recipes)
    dataSource?.apply(snapshot, animatingDifferences: animated)
    if Model.currentModel.recipes.isEmpty {
      let label = UILabel()
      label.text = "No Recipes Found"
      label.textColor = UIColor.systemGray2
      label.textAlignment = .center
      label.font = UIFont.preferredFont(forTextStyle: .title2)
      tableView.backgroundView = label
    } else {
      tableView.backgroundView = nil
    }
  }
}

// MARK: - CLLocationManagerDelegate
extension NearbyTableViewController: CLLocationManagerDelegate {
  func setupLocationManager() {
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    
    // Only look at locations within a 0.5 km radius.
    locationManager.distanceFilter = 500.0
    locationManager.delegate = self
    
    CLLocationManager.authorizationStatus()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)  {
    switch status {
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .authorizedWhenInUse:
      manager.startUpdatingLocation()
    default:
      // Do nothing.
      print("Other status")
    }
  }
}
