import UIKit

class UsersTableViewController: UITableViewController {
  // MARK: - Properties
  var users: [User] = []
  let usersRequest = ResourceRequest<User>(resourcePath: "users")

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
    usersRequest.getAll { [weak self] result in
      DispatchQueue.main.async {
        sender?.endRefreshing()
      }
      switch result {
      case .failure:
        ErrorPresenter.showError(
          message: "There was an error getting the users",
          on: self)
      case .success(let users):
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.users = users
          self.tableView.reloadData()
        }
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension UsersTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let user = users[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
    cell.textLabel?.text = user.name
    cell.detailTextLabel?.text = user.username
    return cell
  }
}
