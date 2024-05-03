import SwiftUI

@main
struct SousApp: App {
    @StateObject private var dataController = DataController()
    @AppStorage("hasOnboarded") var hasOnboarded = false
    
    var body: some Scene {
        WindowGroup {
            if !hasOnboarded {
                OnboardingView(dataController: dataController)
                    .onDisappear {
                        hasOnboarded = true
                    }
            } else {
                ContentView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
            }
        }
    }
}
