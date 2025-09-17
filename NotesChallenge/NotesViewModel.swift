import Foundation

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }

    private let notesKey = "user_notes"
    private let passwordKey = "note_password"

    init() {
        loadNotes()
    }

    // Notes section
    func createNote(content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let encryptedTrimmed = md5(from: trimmed)

        let newNote = Note(content: String(encryptedTrimmed))
        notes.append(newNote)
    }

    func updateNote(id: UUID, newContent: String) {
        let trimmed = newContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let encryptedTrimmed = md5(from: trimmed)

        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].content = String(encryptedTrimmed)
        }
    }

    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }

    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }

    // Password section
    func isPasswordSet() -> Bool {
        return UserDefaults.standard.string(forKey: passwordKey) != nil
    }

    func validatePassword(_ input: String) -> Bool {
        return input == UserDefaults.standard.string(forKey: passwordKey)
    }

    func savePassword(_ password: String) {
        UserDefaults.standard.set(password, forKey: passwordKey)
    }
}

