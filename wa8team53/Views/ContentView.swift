import SwiftUI
import FirebaseAuth


struct ContentView: View {
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                MainView()
                    .environmentObject(viewModel)
            } else {
                LoginView()
                    .environmentObject(viewModel)  
            }
        }
    }
}




