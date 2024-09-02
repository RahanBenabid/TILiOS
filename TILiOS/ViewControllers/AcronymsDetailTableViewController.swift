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

class AcronymDetailTableViewController: UITableViewController {
  // MARK: - Properties
  var acronym: Acronym {
    didSet {
      updateAcronymView()
    }
  }
  
  var user: User? {
    didSet {
      updateAcronymView()
    }
  }
  
  var categories: [Category] {
    didSet {
      updateAcronymView()
    }
  }
  
  // MARK: - Initializers
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not implemented")
  }
  
  init?(coder: NSCoder, acronym: Acronym) {
    self.acronym = acronym
    self.categories = []
    super.init(coder: coder)
  }
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.prefersLargeTitles = false
    getAcronymData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    getAcronymData()
  }
  
  // MARK: - Model Loading
  
  func getAcronymData() {
    // ensures the acronym ID in not null
    guard let id = acronym.id else {
      return
    }
    
    // create AcronymRequest to gather infos
    let acronymDetailRequester = AcronymRequest(acronymID: id)
    // get the acronym's user
    acronymDetailRequester.getUser { [weak self] result in
      switch result {
        // if success, update the user props
      case .success(let user):
        self?.user = user
      case .failure:
        let message = "There was an error getting the acronym's user"
      }
    }
    
    // get the acronym's category
    acronymDetailRequester.getCategories { [weak self] result in
      switch result {
        // if success, update the categories props
      case .success(let categories):
        self?.categories = categories
      case .failure:
        let message = "There was an error getting the acronym's categories"
        ErrorPresenter.showError(message: message, on: self)
      }
    }
  }
  
  func updateAcronymView() {
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
    }
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "EditAcronymSegue" {
      // makes sure the destination is a CreateUserTableViewController
      guard
        let destination = segue.destination
          as? CreateAcronymTableViewController else {
        return
      }
      
      // set the properties on the destination
      destination.selectedUser = user
      destination.acronym = acronym
    }
  }
  
  @IBSegueAction func makeAddToCategoryController(_ coder: NSCoder) -> AddToCategoryTableViewController? {
    AddToCategoryTableViewController(
      coder: coder,
      acronym: acronym,
      selectedCategories: categories)
  }
  
  
  // MARK: - IBActions
  @IBAction func updateAcronymDetails(_ segue: UIStoryboardSegue) {
    guard let controller = segue.source
            as? CreateAcronymTableViewController else {
      return
    }
    
    user = controller.selectedUser
    if let acronym = controller.acronym {
      self.acronym = acronym
    }
  }
}

// MARK: - UITableViewDataSource
extension AcronymDetailTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 3 ? categories.count : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AcronymDetailCell", for: indexPath)
    switch indexPath.section {
    case 0:
      cell.textLabel?.text = acronym.short
    case 1:
      cell.textLabel?.text = acronym.long
    case 2:
      cell.textLabel?.text = user?.name
    case 3:
      cell.textLabel?.text = categories[indexPath.row].name
      // Set the table cell title to “Add To Category” if the cell is in the new section
    case 4:
      cell.textLabel?.text = "Add To Category"
    default:
      break
    }
    
    // This allows a user to select the new row but no others
    if indexPath.section  == 4 {
      cell.selectionStyle = .default
      cell.isUserInteractionEnabled = true
    } else {
      cell.selectionStyle = .none
      cell.isUserInteractionEnabled = false
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Acronym"
    case 1:
      return "Meaning"
    case 2:
      return "User"
    case 3:
      return "Categories"
    default:
      return nil
    }
  }
}
