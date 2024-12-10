import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct AddMembersView: View {
    let group: StudyGroup
    @Environment(\.dismiss) private var dismiss
    @State private var allUsers: [AppUser] = []
    @State private var selectedUsers: Set<String> = []
    
    var body: some View {
        NavigationView {
            List(allUsers) { user in
                if !group.members.contains(user.id) {
                    Button {
                        if selectedUsers.contains(user.id) {
                            selectedUsers.remove(user.id)
                        } else {
                            selectedUsers.insert(user.id)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            if selectedUsers.contains(user.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Add Group Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addMembers()
                    }
                    .disabled(selectedUsers.isEmpty)
                }
            }
        }
        .onAppear {
            fetchAllUsers()
        }
    }
    
    private func fetchAllUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            
            allUsers = snapshot?.documents.compactMap { document in
                guard let name = document.data()["name"] as? String,
                      let email = document.data()["email"] as? String else {
                    return nil
                }
                return AppUser(id: document.documentID, name: name, email: email)
            } ?? []
        }
    }
    
    private func addMembers() {
        let db = Firestore.firestore()
        db.collection("groups").document(group.id).updateData([
            "members": FieldValue.arrayUnion(Array(selectedUsers))
        ]) { error in
            if let error = error {
                print("Error adding members: \(error)")
            }
            dismiss()
        }
    }
}
