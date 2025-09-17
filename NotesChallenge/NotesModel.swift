import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    var content: String

    init(id: UUID = UUID(), content: String) {
        self.id = id
        self.content = content
    }
}
