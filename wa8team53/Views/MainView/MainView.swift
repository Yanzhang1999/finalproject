
import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                TabView {
                    StudyView()
                        .tabItem {
                            Label("Study", systemImage: "timer")
                        }
                    
                    GroupView()
                        .tabItem {
                            Label("Group", systemImage: "person.3")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("My", systemImage: "person")
                        }
                }
                .environmentObject(viewModel)
            } else {
                LoginView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            viewModel.checkAuthStatus()
        }
    }
}

#Preview {
    MainView()
}
