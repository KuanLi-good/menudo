import SwiftUI
import PushNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    @AppStorage("customerId") var customerId: String = ""
    let pushNotifications = PushNotifications.shared
       
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     self.pushNotifications.start(instanceId: "a2f5374e-6c0b-43d2-a4ff-2343518d63ec")
     self.pushNotifications.registerForRemoteNotifications()
     return true
   }
   
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
     self.pushNotifications.registerDeviceToken(deviceToken) {
         try? self.pushNotifications.subscribe(interest: "complete_" + self.customerId)
     }
   }

}


