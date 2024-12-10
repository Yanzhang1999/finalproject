import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    func signIn(email: String, password: String) async throws -> AppUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return try await fetchUser(userId: result.user.uid)
    }

    func signUp(email: String, password: String, name: String) async throws -> AppUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(result.user.uid).setData(userData)
        return try await fetchUser(userId: result.user.uid)
    }
    
    private func fetchUser(userId: String) async throws -> AppUser {
        let document = try await db.collection("users").document(userId).getDocument()
        guard let data = document.data(),
              let name = data["name"] as? String,
              let email = data["email"] as? String else {
            throw NSError(domain: "FirebaseService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user"])
        }
        
        return AppUser(id: document.documentID, name: name, email: email)
    }

    
    func createStudySession(userId: String, duration: Int) async throws -> StudySession {
        let sessionData: [String: Any] = [
            "userId": userId,
            "duration": duration,
            "startTime": FieldValue.serverTimestamp(),
            "isCompleted": false
        ]
        
        let docRef = try await db.collection("study_sessions").addDocument(data: sessionData)
        let document = try await docRef.getDocument()
        
        guard let session = StudySession(document: document) else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create session"])
        }
        return session
    }
    
    func completeStudySession(sessionId: String) async throws {
        try await db.collection("study_sessions").document(sessionId).updateData([
            "isCompleted": true
        ])
    }
    
    func createGroup(name: String, userId: String) async throws -> StudyGroup {
        let groupData: [String: Any] = [
            "name": name,
            "createdBy": userId,
            "members": [userId],
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        let docRef = try await db.collection("groups").addDocument(data: groupData)
        let document = try await docRef.getDocument()
        
        guard let group = StudyGroup(document: document) else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create group"])
        }
        return group
    }
    
    func joinGroup(groupId: String, userId: String) async throws {
        try await db.collection("groups").document(groupId).updateData([
            "members": FieldValue.arrayUnion([userId])
        ])
    }
}
