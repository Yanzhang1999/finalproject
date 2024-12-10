import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: register) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Register")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading)
                
                Spacer()
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func register() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter all space"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Password is not the Same"
            return
        }
        
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user else { return }
            
            let db = Firestore.firestore()
            let userData = [
                "name": name,
                "email": email,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("users").document(user.uid).setData(userData) { error in
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                dismiss()
            }
        }
    }
}
