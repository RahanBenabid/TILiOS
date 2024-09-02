import Foundation

struct ResourceRequest<ResourceType> where ResourceType: Codable {
	let baseURL = "http://localhost:8080/api/"
	let resourceURL: URL
	
	init(resourcePath: String) {
		guard let resourceURL = URL(string: baseURL) else {
			fatalError("Failed to convert baseURL to a URL")
		}
		self.resourceURL =
		resourceURL.appendingPathComponent(resourcePath)
	}
	
	func getAll(completion: @escaping (Result<[ResourceType], ResourceRequestError>) -> Void) {
		let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, _ in
			guard let jsonData = data else {
				completion(.failure(.noData))
				return
			}
			do {
				let resources = try JSONDecoder().decode([ResourceType].self, from: jsonData)
				completion(.success(resources))
			} catch {
				completion(.failure(.decodingError))
			}
		}
		dataTask.resume()
	}
	
	func save<CreateType>(
		_ saveData: CreateType,
		completion: @escaping (Result<ResourceType, ResourceRequestError>) -> Void
	) where CreateType: Codable {
		do {
			// we no longer need to provide a user thanks to the tokens
			// get the token, if it doesn't exist, then go to the login screen
			guard let token = Auth().token else {
				Auth().logout()
				return
			}
			var urlRequest = URLRequest(url: resourceURL)
			urlRequest.httpMethod = "POST"
			urlRequest.httpBody = try JSONEncoder().encode(saveData)
			urlRequest.addValue(
				"application/json",
				forHTTPHeaderField: "Content-Type")
			// we add the token to the request using the header
			urlRequest.addValue(
				"Bearer \(token)",
				forHTTPHeaderField: "Authorization")
			let dataTask = URLSession.shared
				.dataTask(with: urlRequest) { data, response, _ in
					guard let httpResponse = response as? HTTPURLResponse else {
						completion(.failure(.noData))
						return
					}
					guard
						httpResponse.statusCode == 200,
						let jsonData = data
					else {
						if httpResponse.statusCode == 401 {
							Auth().logout()
						}
						completion(.failure(.noData))
						return
					}
					
					do {
						let resource = try JSONDecoder().decode(ResourceType.self, from: jsonData)
						completion(.success(resource))
					} catch {
						completion(.failure(.decodingError))
					}
				}
			dataTask.resume()
		} catch {
			completion(.failure(.encodingError))
		}
	}
}
