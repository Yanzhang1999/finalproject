import Foundation
import FirebaseAuth
import FirebaseFirestore
class MainViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AppUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func checkAuthStatus() {
        isAuthenticated = Auth.auth().currentUser != nil
        if isAuthenticated {
            fetchUserData()
        }
    }
    
    func fetchUserData() {
       guard let userId = Auth.auth().currentUser?.uid else { return }
       
       isLoading = true
       db.collection("users").document(userId).getDocument(source: .default) { [weak self] document, error in
           self?.isLoading = false
           
           if let error = error {
               self?.errorMessage = error.localizedDescription
               return
           }
           
           if let document = document,
              let data = document.data(),
              let name = data["name"] as? String,
              let email = data["email"] as? String {
               self?.currentUser = AppUser(id: userId, name: name, email: email)
           } else {
               self?.errorMessage = "Failed to fetch user data"
           }
       }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
