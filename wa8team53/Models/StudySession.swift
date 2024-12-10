import Foundation
import FirebaseFirestore

struct StudySession: Identifiable, Codable {
    let id: String
    let userId: String
    let startTime: Date
    let duration: Int  // 分钟
    var isCompleted: Bool
    
    init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let userId = data["userId"] as? String,
            let duration = data["duration"] as? Int,
            let startTime = (data["startTime"] as? Timestamp)?.dateValue(),
            let isCompleted = data["isCompleted"] as? Bool
        else {
            return nil
        }
        
        self.id = document.documentID
        self.userId = userId
        self.startTime = startTime
        self.duration = duration
        self.isCompleted = isCompleted
    }
}


import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    
    init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let name = data["name"] as? String,
            let email = data["email"] as? String
        else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.email = email
    }
}
