import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@main
struct PinetumApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                          GIDSignIn.sharedInstance.handle(url)
                        }
        }

    }
}
