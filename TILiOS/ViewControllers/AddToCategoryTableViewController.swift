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

class AddToCategoryTableViewController: UITableViewController {
  // MARK: - Properties
  private var categories: [Category] = []
  private let selectedCategories: [Category]
  private let acronym: Acronym
  
  // MARK: - Initialization
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not implemented")
  }
  
  init?(coder: NSCoder, acronym: Acronym, selectedCategories: [Category]) {
    self.acronym = acronym
    self.selectedCategories = selectedCategories
    super.init(coder: coder)
  }
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
  }
  
  func loadData() {
    // Create a ResourceRequest for the "categories" endpoint
    let categoriesRequest = ResourceRequest<Category>(resourcePath: "categories")
    
    // Perform a request to get all categories
    categoriesRequest.getAll { [weak self] result in
      // Handle the result of the request
      switch result {
      case .failure:
        // If the request fails, show an error message
        let message = "There was an error getting the categories"
        ErrorPresenter.showError(message: message, on: self) // Present the error on the current view controller
        
      case .success(let categories):
        // If the request is successful, store the retrieved categories
        self?.categories = categories
        
        // Update the UI on the main thread
        DispatchQueue.main.async { [weak self] in
          // Reload the table view to display the new categories
          self?.tableView.reloadData()
        }
      }
    }
  }
  
}

// MARK: - UITableViewDataSource
extension AddToCategoryTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let category = categories[indexPath.row]
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    cell.textLabel?.text = category.name
    
    let isSelected = selectedCategories.contains { element in
      element.name == category.name
    }
    
    if isSelected {
      cell.accessoryType = .checkmark
    }
    
    return cell
  }
}


// MARK: - UITableViewDelegate
extension AddToCategoryTableViewController {
  override func tableView(
    _
    tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    // 1
    let category = categories[indexPath.row]
    // 2
    guard let acronymID = acronym.id else {
      let message = """
        There was an error adding the acronym
        to the category - the acronym has no ID
        """
      ErrorPresenter.showError(message: message, on: self)
      return
    }
    // 3
    let acronymRequest = AcronymRequest(acronymID: acronymID)
    acronymRequest
      .add(category: category) { [weak self] result in
        switch result {
          // 4
        case .success:
          DispatchQueue.main.async { [weak self] in
            self?.navigationController?
              .popViewController(animated: true)
          }
          // 5
        case .failure:
          let message = """
            There was an error adding the acronym
            to the category
            """
          ErrorPresenter.showError(message: message, on: self)
        }
      }
  }
}
