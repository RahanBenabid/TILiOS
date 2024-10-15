import Foundation

final class Category: Codable {
  var id: UUID?
  var name: String

  init(name: String) {
    self.name = name
  }
}
