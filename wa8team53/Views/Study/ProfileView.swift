import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    
    var body: some View {
        List {
            Section("Personal Information") {
                if let user = viewModel.currentUser {
                    Text("Name: \(user.name)")
                    Text("Email: \(user.email)")
                }
            }
            
            Section("Study Statistic") {
                Text("累计学习时长: 0小时")
                Text("完成专注次数: 0次")
                Text("当前连续打卡: 0天")
            }
            
            Section {
                Button("Logout") {
                    viewModel.signOut()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Personal Center")
    }
}
