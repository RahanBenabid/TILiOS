import Foundation

final class Token: Codable {
  var id: UUID?
  var value: String

  init(value: String) {
    self.value = value
  }
}
