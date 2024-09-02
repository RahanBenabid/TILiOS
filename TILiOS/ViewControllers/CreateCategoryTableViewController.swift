/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
			let name = nameTextField.text, // Get the text from the nameTextField
			!name.isEmpty // Ensure the text is not empty
		else {
			// If the name is empty, show an error message
			ErrorPresenter.showError(
				message: "You must specify a name", // Error message
				on: self) // Present the error on the current view controller
			return // Exit the function if the name is invalid
		}
		
		// Create a new Category object with the specified name
		let category = Category(name: name)
		
		// Create a ResourceRequest for the "categories" endpoint and save the new category
		ResourceRequest<Category>(resourcePath: "categories")
			.save(category) { [weak self] result in // Save the category and handle the result
				switch result {
				case .failure:
					// If saving fails, show an error message
					let message = "There was a problem saving the category"
					ErrorPresenter.showError(message: message, on: self) // Present the error
				case .success:
					// If saving is successful
					DispatchQueue.main.async { [weak self] in
						// Navigate back to the previous view controller
						self?.navigationController?
							.popViewController(animated: true) // Animate the transition back
					}
				}
			}
	}
	
}
