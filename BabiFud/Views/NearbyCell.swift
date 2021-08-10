import UIKit

class NearbyCell: UITableViewCell {
  // MARK: - Outlets
  @IBOutlet private weak var placeImageView: UIImageView!
  @IBOutlet private weak var name: UILabel!
/*
  var establishment: Establishment? {
    didSet {
      placeImageView.image = nil
      name.text = establishment?.name
      establishment?.loadCoverPhoto { [weak self] image in
        guard let self = self else { return }
        self.placeImageView.image = image
      }
    }
  }
 */
  var recipe: Recipe? {
    didSet {
      placeImageView.downloaded(from: recipe!.recipeURL)
      //UIImage image = downloaded(from: recipe!.recipeURL)
      //placeImageView.image = UIImage(named: "breadImage")
      //placeImageView.image = nil
      name.text = recipe?.name.capitalized
    }
  }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
