import SwiftUI
import FirebaseAuth
struct LoginView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("StudyGuard")
                .font(.largeTitle)
                .bold()
                .padding(.top, 100)
            
            TextField("email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
            
            SecureField("password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Login In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 50)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(isLoading)
            
            Button("No account? Register Now") {
                showRegister = true
            }
            .foregroundColor(.blue)
            
            Spacer()
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                print("Login In Error: \(error.localizedDescription)")
                return
            }
            viewModel.checkAuthStatus()
        }
    }
}
