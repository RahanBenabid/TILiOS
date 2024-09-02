import Foundation
import UIKit

enum AuthResult {
	case success
	case failure
}

class Auth {
	static let keychainKey = "TIL-API-KEY"
	
	var token: String? {
		get {
			Keychain.load(key: Auth.keychainKey)
		}
		set {
			if let newToken = newValue {
				Keychain.save(key: Auth.keychainKey, data: newToken)
			} else {
				Keychain.delete(key: Auth.keychainKey)
			}
		}
	}
	
	func logout() {
		// deletes any existing token
		token = nil
		DispatchQueue.main.async {
			guard let applicationDelegate = UIApplication.shared.delegate as? AppDelegate else {
				return
			}
			// loads `Login.storyBoard` and goes to login screen
			let rootController = UIStoryboard(name: "Login", bundle: Bundle.main)
				.instantiateViewController(withIdentifier: "LoginNavigation")
			applicationDelegate.window?.rootViewController = rootController
		}
	}
	
	func login(
		username: String,
		password: String,
		completion: @escaping (AuthResult) -> Void
	) {
		// API endpoint for login
		let path = "http://localhost:8080/api/users/login"
		guard let url = URL(string: path) else {
			fatalError("Failed to convert URL")
		}
		
		// Encode credentials to Base64
		guard let loginString = "\(username):\(password)"
			.data(using: .utf8)?
			.base64EncodedString()
		else {
			fatalError("Failed to encode credentials")
		}
		
		// Prepare login request
		var loginRequest = URLRequest(url: url)
		loginRequest.addValue("Basic \(loginString)",
													forHTTPHeaderField: "Authorization")
		loginRequest.httpMethod = "POST"
		
		// Create and execute network request
		let dataTask = URLSession.shared
			.dataTask(with: loginRequest) { data, response, _ in
				// Check for successful response
				guard
					let httpResponse = response as? HTTPURLResponse,
					httpResponse.statusCode == 200,
					let jsonData = data
				else {
					completion(.failure)
					return
				}
				
				// Decode token and complete login
				do {
					// decode response body into a token
					let token = try JSONDecoder()
						.decode(Token.self, from: jsonData)
					// save and retreive the token as the Auth token
					self.token = token.value
					completion(.success)
				} catch {
					completion(.failure)
				}
			}
		// start the data task to send the request request
		dataTask.resume()
	}
}
