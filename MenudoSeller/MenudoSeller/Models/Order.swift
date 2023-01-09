import Foundation
import SwiftUI

struct Order: Identifiable {
    var id: String
    var seller: String
    var items: [String]
    var total_price: Double
    var customer: String
    
    var toParams: [String: Any] {
            return [
                "id" : id as Any,
                "seller" : seller as Any,
                "items" : items as Any,
                "total_price" : total_price as Any,
                "customer" : customer as Any
            ]
    }

}


class OrderList: ObservableObject {
    @Published private(set) var orders: [Order] = []
    
    func set(list: [Order]) {
        orders.removeAll()
        orders.append(contentsOf: list)
    }
    
    func complete(order: Order) {
        orders = orders.filter { $0.id != order.id }
    }
    
}

