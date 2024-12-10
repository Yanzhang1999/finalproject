import Foundation
import FirebaseFirestore

struct StudyGroup: Identifiable, Codable {
    let id: String
    let name: String
    let createdBy: String
    var members: [String]
    let createdAt: Date
    
    init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let name = data["name"] as? String,
            let createdBy = data["createdBy"] as? String,
            let members = data["members"] as? [String],
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
        else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.createdBy = createdBy
        self.members = members
        self.createdAt = createdAt
    }
    
    init(id: String, name: String, createdBy: String, members: [String], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.createdBy = createdBy
        self.members = members
        self.createdAt = createdAt
    }
}
