import UIKit

class CreateCategoryTableViewController: UITableViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var nameTextField: UITextField!

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
    // Check if the name text field has a value and is not empty
    guard
      let name = nameTextField.text,  // Get the text from the nameTextField
      !name.isEmpty  // Ensure the text is not empty
    else {
      // If the name is empty, show an error message
      ErrorPresenter.showError(
        message: "You must specify a name",  // Error message
        on: self)  // Present the error on the current view controller
      return  // Exit the function if the name is invalid
    }

    // Create a new Category object with the specified name
    let category = Category(name: name)

    // Create a ResourceRequest for the "categories" endpoint and save the new category
    ResourceRequest<Category>(resourcePath: "categories")
      .save(category) { [weak self] result in  // Save the category and handle the result
        switch result {
        case .failure:
          // If saving fails, show an error message
          let message = "There was a problem saving the category"
          ErrorPresenter.showError(message: message, on: self)  // Present the error
        case .success:
          // If saving is successful
          DispatchQueue.main.async { [weak self] in
            // Navigate back to the previous view controller
            self?.navigationController?
              .popViewController(animated: true)  // Animate the transition back
          }
        }
      }
  }

}
