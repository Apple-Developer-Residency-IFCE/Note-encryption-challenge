import SwiftUI

struct NotesView: View {
    @State private var viewModel = NotesViewModel()

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $viewModel.newNoteContent)
                    .border(Color.gray.opacity(0.5))
                    .frame(height: 100)
                    .padding()

                Button(action: viewModel.manageNewContent) {
                    Text(viewModel.editingNote == nil ? "Create Note" : "Update Note")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.newNoteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding()

                List {
                    ForEach(viewModel.notes) { note in
                        Text(note.content)
                            .onTapGesture {
                                viewModel.editingNote = note
                                viewModel.newNoteContent = note.content
                            }
                    }
                }
            }
            .navigationTitle("Notes Challenge")
            .alert(viewModel.isCreatingPassword ? "Create Password" : "Enter Password", isPresented: $viewModel.showPasswordPrompt, actions: {
                SecureField("Password", text: $viewModel.passwordInput)
                Button("OK") { viewModel.managePassword() }
                Button("Cancel", role: .cancel) { viewModel.cancelPassowrdManagement()}
            })
            .alert("Invalid Password", isPresented: $viewModel.showInvalidPasswordAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Password cannot be empty", isPresented: $viewModel.showEmptyPasswordAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
}



