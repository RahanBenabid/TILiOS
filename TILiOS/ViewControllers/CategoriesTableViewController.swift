import UIKit

class CategoriesTableViewController: UITableViewController {
  // MARK: - Properties
  var categories: [Category] = []
  let categoriesRequest = ResourceRequest<Category>(resourcePath: "categories")

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refresh(nil)
  }

  // MARK: - IBActions
  @IBAction func refresh(_ sender: UIRefreshControl?) {
    categoriesRequest.getAll { [weak self] result in
      DispatchQueue.main.async {
        sender?.endRefreshing()
      }
      switch result {
      case .failure:
        let message = "There was an error getting the categories"
        ErrorPresenter.showError(message: message, on: self)
      case .success(let categories):
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.categories = categories
          self.tableView.reloadData()
        }
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension CategoriesTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    cell.textLabel?.text = categories[indexPath.row].name
    return cell
  }
}
