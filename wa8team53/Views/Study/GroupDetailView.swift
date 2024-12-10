import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine


struct StudyStats: Identifiable {
    let id = UUID()
    let userId: String
    let totalTime: Int
    let sessionCount: Int
    let userName: String
}


struct GroupDetailView: View {
    let group: StudyGroup
    @State private var members: [AppUser] = []
    @State private var showingQRCode = false
    @State private var showingAddMembers = false
    @State private var memberStats: [StudyStats] = []
    @State private var groupTotalTime: Int = 0
    @EnvironmentObject private var viewModel: MainViewModel
    
    var body: some View {
        List {
            Section("Group Info") {
                Text("Group Name: \(group.name)")
                Text("Create Time: \(group.createdAt.formatted())")
                
                Button("Show Group QR Code") {
                    showingQRCode = true
                }
            }
            
            Section("Study Statistic") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Group study time for all members")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(formatTime(minutes: groupTotalTime))
                            .font(.title2)
                            .bold()
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            Section("Members' Study Rank") {
                if memberStats.isEmpty {
                    Text("No Study Record")
                        .foregroundColor(.gray)
                } else {
                    ForEach(memberStats) { stat in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(stat.userName)
                                    .font(.headline)
                                Text("complete \(stat.sessionCount) times study")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(formatTime(minutes: stat.totalTime))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Section {
                if group.createdBy == viewModel.currentUser?.id {
                    Button("Add member") {
                        showingAddMembers = true
                    }
                }
            }
        }
        .navigationTitle("Group Detail")
        .sheet(isPresented: $showingQRCode) {
            QRCodeView(groupId: group.id)
        }
        .sheet(isPresented: $showingAddMembers) {
            AddMembersView(group: group)
        }
        .onAppear {
            fetchMembers()
            fetchStudyStats()
        }
    }
    
    private func fetchMembers() {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField(FieldPath.documentID(), in: group.members)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching members: \(error)")
                    return
                }
                
                members = snapshot?.documents.compactMap { document in
                    guard let name = document.data()["name"] as? String,
                          let email = document.data()["email"] as? String else {
                        return nil
                    }
                    return AppUser(id: document.documentID, name: name, email: email)
                } ?? []
                
                fetchStudyStats()
            }
    }
    
    private func fetchStudyStats() {
        let db = Firestore.firestore()
        memberStats = []
        groupTotalTime = 0
        
        for memberId in group.members {
            db.collection("study_sessions")
                .whereField("userId", isEqualTo: memberId)
                .whereField("isCompleted", isEqualTo: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching stats: \(error)")
                        return
                    }
                    
                    let sessionCount = snapshot?.documents.count ?? 0
                    let totalTime = snapshot?.documents.reduce(0) { sum, doc in
                        sum + (doc.data()["duration"] as? Int ?? 0)
                    } ?? 0
                    
                    if let member = members.first(where: { $0.id == memberId }) {
                        let stat = StudyStats(
                            userId: memberId,
                            totalTime: totalTime,
                            sessionCount: sessionCount,
                            userName: member.name
                        )
                        memberStats.append(stat)
                        groupTotalTime += totalTime
                        
                        memberStats.sort { $0.totalTime > $1.totalTime }
                    }
                }
        }
    }
    
    private func formatTime(minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)Minutes"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)小时\(mins)分钟" : "\(hours)小时"
        }
    }
}
