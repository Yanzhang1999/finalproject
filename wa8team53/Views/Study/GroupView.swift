import SwiftUI
import FirebaseFirestore
import AVFoundation


struct GroupView: View {
   @EnvironmentObject private var viewModel: MainViewModel
   @State private var groups: [StudyGroup] = []
   @State private var isShowingCreateGroup = false
   @State private var isShowingScanner = false
   @State private var scannedCode: String?
   
   var body: some View {
       NavigationView {
           List {
               ForEach(groups) { group in
                   GroupRow(group: group)
               }
           }
           .navigationTitle("Study Group")
           .toolbar {
               ToolbarItem(placement: .navigationBarTrailing) {
                   HStack {
                       Button(action: { isShowingScanner = true }) {
                           Image(systemName: "qrcode.viewfinder")
                       }
                       
                       Button(action: { isShowingCreateGroup = true }) {
                           Image(systemName: "plus")
                       }
                   }
               }
           }
           .sheet(isPresented: $isShowingCreateGroup) {
               CreateGroupView(isPresented: $isShowingCreateGroup)
           }
           .sheet(isPresented: $isShowingScanner) {
               QRScannerView(scannedCode: $scannedCode, isShowingScanner: $isShowingScanner)
           }
           .onChange(of: scannedCode) { newCode in
               if let code = newCode {
                   joinGroupWithCode(code)
               }
           }
           .onAppear {
               fetchGroups()
           }
       }
   }
   
   private func fetchGroups() {
       let db = Firestore.firestore()
       guard let userId = viewModel.currentUser?.id else { return }
       
       let groupsRef = db.collection("groups")
           .whereField("members", arrayContains: userId)
       
       groupsRef.addSnapshotListener { querySnapshot, error in
           if let error = error {
               print("Error fetching groups: \(error.localizedDescription)")
               return
           }
           
           self.processGroupDocuments(querySnapshot?.documents ?? [])
       }
   }
   
   private func processGroupDocuments(_ documents: [QueryDocumentSnapshot]) {
       groups = documents.compactMap { document in
           let data = document.data()
           return createStudyGroup(document: document, data: data)
       }
   }
   
   private func createStudyGroup(document: QueryDocumentSnapshot, data: [String: Any]) -> StudyGroup? {
       guard let name = data["name"] as? String,
             let createdBy = data["createdBy"] as? String,
             let members = data["members"] as? [String],
             let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
       else {
           return nil
       }
       
       return StudyGroup(
           id: document.documentID,
           name: name,
           createdBy: createdBy,
           members: members,
           createdAt: createdAt
       )
   }
   
   private func joinGroupWithCode(_ code: String) {
       guard let userId = viewModel.currentUser?.id else { return }
       let db = Firestore.firestore()
       
       db.collection("groups").document(code).updateData([
           "members": FieldValue.arrayUnion([userId])
       ]) { error in
           if let error = error {
               print("Error joining group: \(error.localizedDescription)")
           } else {
               print("Successfully joined group")
           }
           scannedCode = nil
       }
   }
}


struct GroupRow: View {
    let group: StudyGroup
    
    var body: some View {
        NavigationLink(destination: GroupDetailView(group: group)) {
            VStack(alignment: .leading) {
                Text(group.name)
                    .font(.headline)
                Text("Members Number: \(group.members.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}



struct CreateGroupView: View {
   @Binding var isPresented: Bool
   @State private var groupName = ""
   @State private var groupId: String?
   @State private var showingQRCode = false
   @EnvironmentObject private var viewModel: MainViewModel
   
   var body: some View {
       NavigationView {
           Form {
               TextField("Group Name", text: $groupName)
               
               if let groupId = groupId {
                   Section {
                       Button("Show QR Code") {
                           showingQRCode = true
                       }
                   }
               }
           }
           .navigationTitle("Create Group")
           .navigationBarTitleDisplayMode(.inline)
           .toolbar {
               ToolbarItem(placement: .cancellationAction) {
                   Button("Cancel") {
                       isPresented = false
                   }
               }
               
               ToolbarItem(placement: .confirmationAction) {
                   Button("Create") {
                       createGroup()
                   }
                   .disabled(groupName.isEmpty)
               }
           }
           .sheet(isPresented: $showingQRCode) {
               if let groupId = groupId {
                   QRCodeView(groupId: groupId)
               }
           }
       }
   }
   
    private func createGroup() {
       let db = Firestore.firestore()
       guard let userId = viewModel.currentUser?.id else { return }
       
       let groupData: [String: Any] = [
           "name": groupName,
           "createdBy": userId,
           "members": [userId],
           "createdAt": FieldValue.serverTimestamp()
       ]
       
       let docRef = db.collection("groups").document()
       self.groupId = docRef.documentID  
       
       docRef.setData(groupData) { error in
           if let error = error {
               print("Error creating group: \(error)")
               return
           }
           self.isPresented = false
       }
    }


}
