import Foundation

@Observable
class NotesViewModel{
    var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }

    private let notesKey = "user_notes"
    private let passwordKey = "note_password"
    
    var newNoteContent: String = ""
    var editingNote: Note?
    var showPasswordPrompt = false
    var passwordInput = ""
    var showInvalidPasswordAlert = false
    var showEmptyPasswordAlert = false
    var pendingAction: (() -> Void)? = nil
    var isCreatingPassword = false

    init() {
        loadNotes()
    }

    // Notes section
    func createNote(content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let encryptedTrimmed = CryptoWorker.md5(from: trimmed)

        let newNote = Note(content: String(encryptedTrimmed))
        notes.append(newNote)
    }

    func updateNote(id: UUID, newContent: String) {
        let trimmed = newContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let encryptedTrimmed = CryptoWorker.md5(from: trimmed)

        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].content = String(encryptedTrimmed)
        }
    }

    private func saveNotes() {
        do {
            let encoded = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(encoded, forKey: notesKey)
        } catch {
            print(error)
        }
    }

    private func loadNotes() {
        do {
            guard let data = UserDefaults.standard.data(forKey: notesKey) else { return }
            let decoded = try JSONDecoder().decode([Note].self, from: data)
            notes = decoded
        } catch {
            print(error)
        }
    }

    // Password section
    func isPasswordSet() -> Bool {
        UserDefaults.standard.string(forKey: passwordKey) != nil
    }

    func validatePassword(_ input: String) -> Bool {
        input == UserDefaults.standard.string(forKey: passwordKey)
    }

    func savePassword(_ password: String) {
        UserDefaults.standard.set(password, forKey: passwordKey)
    }
    
    // UI state section
    func manageNewContent() {
        let trimmed = newNoteContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let note = editingNote {
            pendingAction = {
                self.updateNote(id: note.id, newContent: trimmed)
                self.editingNote = nil
                self.newNoteContent = ""
            }
        } else {
            pendingAction = {
                self.createNote(content: trimmed)
                self.newNoteContent = ""
            }
        }
        passwordInput = ""
        if self.isPasswordSet() {
            // Ask to verify password
            isCreatingPassword = false
            showPasswordPrompt = true
        } else {
            // Ask to create new password
            isCreatingPassword = true
            showPasswordPrompt = true
        }
    }
    
    func managePassword() {
        let trimmedPassword = self.passwordInput.trimmingCharacters(in: .whitespacesAndNewlines)

        if self.isCreatingPassword {
            if trimmedPassword.isEmpty {
                self.showEmptyPasswordAlert = true
                return
            }
            self.savePassword(trimmedPassword)
            self.pendingAction?()
        } else {
            if self.validatePassword(trimmedPassword) {
                self.pendingAction?()
            } else {
                self.showInvalidPasswordAlert = true
            }
        }

        self.passwordInput = ""
        self.pendingAction = nil
    }
    
    func cancelPassowrdManagement() {
        self.passwordInput = ""
        self.pendingAction = nil
    }
    
}

