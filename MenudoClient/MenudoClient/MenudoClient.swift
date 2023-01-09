import SwiftUI


@main
struct MenudoClient: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("sellerId") var sellerId: String = ""

    private var hasSeller: Bool {
        !sellerId.isEmpty
    }
    
    var body: some Scene {
        WindowGroup {
            if !hasSeller{
                WelcomeView()
            }
            else {
            ContentView()
            }
        }
    }
    
    
}
