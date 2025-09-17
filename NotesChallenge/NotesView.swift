import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var newNoteContent: String = ""
    @State private var editingNote: Note?
    @State private var showPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var showInvalidPasswordAlert = false
    @State private var showEmptyPasswordAlert = false
    @State private var pendingAction: (() -> Void)? = nil
    @State private var isCreatingPassword = false

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $newNoteContent)
                    .border(Color.gray.opacity(0.5))
                    .frame(height: 100)
                    .padding()

                Button(action: {
                    let trimmed = newNoteContent.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    if let note = editingNote {
                        pendingAction = {
                            viewModel.updateNote(id: note.id, newContent: trimmed)
                            editingNote = nil
                            newNoteContent = ""
                        }
                    } else {
                        pendingAction = {
                            viewModel.createNote(content: trimmed)
                            newNoteContent = ""
                        }
                    }

                    passwordInput = ""
                    if viewModel.isPasswordSet() {
                        // Ask to verify password
                        isCreatingPassword = false
                        showPasswordPrompt = true
                    } else {
                        // Ask to create new password
                        isCreatingPassword = true
                        showPasswordPrompt = true
                    }

                }) {
                    Text(editingNote == nil ? "Create Note" : "Update Note")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(newNoteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding()

                List {
                    ForEach(viewModel.notes) { note in
                        Text(note.content)
                            .onTapGesture {
                                editingNote = note
                                newNoteContent = note.content
                            }
                    }
                }
            }
            .navigationTitle("Notes Challenge")
            .alert(isCreatingPassword ? "Create Password" : "Enter Password", isPresented: $showPasswordPrompt, actions: {
                SecureField("Password", text: $passwordInput)
                Button("OK") {
                    let trimmedPassword = passwordInput.trimmingCharacters(in: .whitespacesAndNewlines)

                    if isCreatingPassword {
                        if trimmedPassword.isEmpty {
                            showEmptyPasswordAlert = true
                            return
                        }
                        viewModel.savePassword(trimmedPassword)
                        pendingAction?()
                    } else {
                        if viewModel.validatePassword(trimmedPassword) {
                            pendingAction?()
                        } else {
                            showInvalidPasswordAlert = true
                        }
                    }

                    passwordInput = ""
                    pendingAction = nil
                }

                Button("Cancel", role: .cancel) {
                    passwordInput = ""
                    pendingAction = nil
                }
            })
            .alert("Invalid Password", isPresented: $showInvalidPasswordAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Password cannot be empty", isPresented: $showEmptyPasswordAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}



