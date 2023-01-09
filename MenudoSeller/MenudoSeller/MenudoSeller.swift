import SwiftUI

@main
struct MenudoSeller: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("email") var email: String = ""
    @AppStorage("full_name") var full_name: String = ""
    @AppStorage("userId") var userId: String = ""

    private var isSignedIn: Bool {
        !userId.isEmpty
    }
        
    var body: some Scene {
        WindowGroup {
            if !isSignedIn{
                SIWAView()
            }
            else {
            ContentView()
            }
            

        }
    }
}
