import SwiftUI

struct WelcomeView: View {
    @AppStorage("sellerId") var sellerId: String = ""
    @AppStorage("restaurant_name") var restaurant_name: String = ""
    @AppStorage("customerId") var customerId: String = ""
    @EnvironmentObject var sellerList: SellerList
    @StateObject var detector = BeaconDetector()
    @State private var inProgress = true
    var found: Bool {
        detector.seller != nil
    }
    
    var body: some View {
        let binding = Binding<Bool>(get: { self.found }, set: { if $0 { self.found} else { !self.found }})
        VStack {
            Image("menudo")
            Text("")
            .alert(isPresented: binding) {
            Alert(
                title: Text("Found Restaurant"),
                message: Text(detector.seller?.restaurant_name ?? ""),
                primaryButton: .destructive(Text("Go")) {
                    print(customerId)
                    inProgress = false
                    self.sellerId = detector.seller?.id ?? ""
                    self.restaurant_name = detector.seller?.restaurant_name ?? ""
                },
                secondaryButton: .cancel()
            )
            }
            
            if (inProgress) {
                ProgressView("Searching Resturants...")
                .progressViewStyle(.circular)
            }
        }

    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
