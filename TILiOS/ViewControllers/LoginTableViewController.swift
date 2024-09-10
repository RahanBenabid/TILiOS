import UIKit
import AuthenticationServices

class LoginTableViewController: UITableViewController {
	// MARK: - Properties
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!

	@IBAction func loginTapped(_ sender: UIBarButtonItem) {
		guard
			let username = usernameTextField.text,
			!username.isEmpty
		else {
			ErrorPresenter.showError(message: "Please enter your username", on: self)
			return
		}

		guard
			let password = passwordTextField.text,
			!password.isEmpty
		else {
			ErrorPresenter.showError(message: "Please enter your password", on: self)
			return
		}

		Auth().login(username: username, password: password) { result in
			switch result {
			case .success:
				DispatchQueue.main.async {
					let appDelegate = UIApplication.shared.delegate as? AppDelegate
					appDelegate?.window?.rootViewController =
						UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
				}
			case .failure:
				let message = "Could not login. Check your credentials and try again"
				ErrorPresenter.showError(message: message, on: self)
			}
		}
	}

	@available(iOS 13.0, *)
	@IBAction func signInWithGoogleButtonTapped(_ sender: UIButton) {
		guard let googleAuthURL = URL(string: "http://127.0.0.1:8080/iOS/login-google")
		else {
			return
		}
		let scheme = "tilapp"
		let session = ASWebAuthenticationSession(url: googleAuthURL, callbackURLScheme: scheme) { callbackURL, error in
			guard
				error == nil,
				let callbackURL = callbackURL
			else {
				return
			}
			let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
			let token = queryItems?.first { $0.name == "token" }?.value
			Auth().token = token
			DispatchQueue.main.async {
				let appDelegate = UIApplication.shared.delegate as? AppDelegate
				appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main)
					.instantiateInitialViewController()
			}
		}
		session.presentationContextProvider = self
		session.start()
	}
}

extension LoginTableViewController: ASWebAuthenticationPresentationContextProviding {
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		guard let window = view.window else {
			fatalError("No windown found in view")
		}
		return window
	}
}
