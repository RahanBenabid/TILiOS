import UIKit

class CreateAcronymTableViewController: UITableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var acronymShortTextField: UITextField!
	@IBOutlet weak var acronymLongTextField: UITextField!
	@IBOutlet weak var userLabel: UILabel!
	
	// MARK: - Properties
	var selectedUser: User?
	var acronym: Acronym?
	
	// MARK: - View Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		acronymShortTextField.becomeFirstResponder()
		if let acronym = acronym {
			// if the acronym is set, then you're in edit mode, and populate the display field with the correct values and update the view's title
			acronymShortTextField.text = acronym.short
			acronymLongTextField.text = acronym.long
			userLabel.text = selectedUser?.name
			navigationItem.title = "Edit Acronym"
		} else {
			// in create mode, call populateUsers()
			populateUsers()
		}
	}
	
	
	// gets users from the API, if the requests fails, it shows an error, if the requests succeeds, set the user field to the first user's name and updates selectedUser
	func populateUsers() {
		let usersRequest = ResourceRequest<User>(resourcePath: "users")
		
		usersRequest.getAll { [weak self] result in
			switch result {
			case .failure:
				let message = "There was an error getting the users"
				ErrorPresenter
					.showError(
						message: message,
						on: self) { _ in
							self?.navigationController?
								.popViewController(animated: true)
						}
			case .success(let users):
				DispatchQueue.main.async { [weak self] in
					self?.userLabel.text = users[0].name
				}
				self?.selectedUser = users[0]
			}
		}
	}
	
	// MARK: - Navigation
	@IBSegueAction func makeSelectUserViewController(_ coder: NSCoder) -> SelectUserTableViewController? {
		// ensures we have a selected user and creates SelectUserTableViewController with that table
		guard let user = selectedUser else {
			return nil
		}
		return SelectUserTableViewController(coder: coder, selectedUser: user)
	}
	
	
	// MARK: - IBActions
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func save(_ sender: UIBarButtonItem) {
		// we ensure all the form is filled
		guard
			let shortText = acronymShortTextField.text,
			!shortText.isEmpty
		else {
			ErrorPresenter.showError(
				message: "You must specify an acronym!",
				on: self)
			return
		}
		
		guard
			let longText = acronymLongTextField.text,
			!longText.isEmpty
		else {
			ErrorPresenter.showError(
				message: "You must specify a meaning!",
				on: self)
			return
		}
		
		guard
			let userID = selectedUser?.id else {
			ErrorPresenter.showError(
				message: "You must have a user to create an acronym!",
				on: self)
			return
		}
		
		// create a new Acronym: using the .toCreateData method, we create a CreateAcronymData
		let acronym = Acronym(
			short: shortText,
			long: longText,
			userID: userID)
		let acronymSavedData = acronym.toCreateData()
		
		// checks if the class's acronym prop is set
		if self.acronym != nil {
			// ensure the ID is valid
			guard let existingID = self.acronym?.id else {
				let message = "There was an error updating the acronym"
				ErrorPresenter.showError(message: message, on: self)
				return
			}
			// Creates an AcronymRequest and update()
			AcronymRequest(acronymID: existingID)
				.update(with: acronymSavedData) { result in
					switch result {
						// in case of failure, display an error
					case .failure(let failure):
						let message = "There was a problem saving the acronym"
						ErrorPresenter.showError(message: message, on: self)
						// otherwise store the updated acronym, and trigger an unwind segue
					case .success(let updatedAcronym):
						DispatchQueue.main.async { [weak self] in
							self?.performSegue(
								withIdentifier: "UpdateAcronymDetails",
								sender: nil)
						}
					}
				}
		} else {
			// create a ResourceRequest fot Acronym and calls the save(_:)
			ResourceRequest<Acronym>(resourcePath: "acronyms")
				.save(acronymSavedData) { [weak self] result in
					switch result {
						// show an error
					case .failure:
						let message = "There was a problem saving the acronym"
						ErrorPresenter.showError(message: message, on: self)
						// return to the previous view
					case .success:
						DispatchQueue.main.async { [weak self] in
							self?.navigationController?
								.popViewController(animated: true)
						}
					}
				}
		}
	}
	
	@IBAction func updateSelectedUser(_ segue: UIStoryboardSegue) {
		// ensures the segue came from the SelectUserTableViewController
		guard let controller = segue.source as? SelectUserTableViewController else {
			return
		}
		// updates selectedUser with the new value and update the user label
		selectedUser = controller.selectedUser
		userLabel.text = selectedUser?.name
	}
}
