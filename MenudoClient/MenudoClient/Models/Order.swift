import Foundation
import SwiftUI

struct Order: Identifiable {
    var id: String = UUID().uuidString
    @AppStorage("sellerId") var seller: String = ""
    @AppStorage("customerId") var customer: String = ""
    var items: [String]
    var total_price: Double
    
    var toParams: [String: Any] {
        if customer.isEmpty {
            self.customer = UUID().uuidString
        }
            return [
                "id" : id as Any,
                "seller" : seller as Any,
                "items" : items as Any,
                "total_price" : total_price as Any,
                "customer" : customer as Any
            ]
    }

}
