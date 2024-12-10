import Foundation
import FirebaseFirestore


struct AppUser: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    

    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
