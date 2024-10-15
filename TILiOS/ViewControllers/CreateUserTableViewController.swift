import UIKit

class CreateUserTableViewController: UITableViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    nameTextField.becomeFirstResponder()
  }

  // MARK: - IBActions
  @IBAction func cancel(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func save(_ sender: Any) {
    guard let name = nameTextField.text, !name.isEmpty else {
      ErrorPresenter.showError(message: "You must specify a name", on: self)
      return
    }

    guard let username = usernameTextField.text, !username.isEmpty else {
      ErrorPresenter.showError(message: "You must specify a username", on: self)
      return
    }

    let user = User(name: name, username: username)
    ResourceRequest<User>(resourcePath: "users").save(user) { [weak self] result in
      switch result {
      case .failure:
        let message = "There was a problem saving the user"
        ErrorPresenter.showError(message: message, on: self)
      case .success:
        DispatchQueue.main.async { [weak self] in
          self?.navigationController?
            .popViewController(animated: true)
        }
      }
    }
  }
}
