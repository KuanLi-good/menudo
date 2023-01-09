import Foundation
import SwiftUI

struct Seller: Codable{
    var id: String
    var email: String?
    var full_name: String?
    var restaurant_name: String?
    var uuid_major: Int = 0
    
    var toParams: [String: Any] {
            return [
                "user" : id as Any,
                "full_name" : full_name as Any,
                "email" : email as Any,
                "restaurant_name" : restaurant_name as Any,
                "uuid_major": uuid_major as Any
            ]
    }
    
    init(id: String, full_name: String?, email: String?, restaurant_name: String?, uuid_major: Int) {
        self.id = id
        self.full_name = full_name
        self.email = email
        self.restaurant_name = restaurant_name
        self.uuid_major = uuid_major
    }
    
    init() {
        self.id = ""
    }

}


class SellerList: ObservableObject {
    @Published private(set) var sellers: [Seller] = []

    func set(list: [Seller]) {
        sellers.removeAll()
        sellers.append(contentsOf: list)
    }
    
    func find_by_major(major: Int) -> Seller? {
        // find one matching uuid major
        if let seller = sellers.first(where: {$0.uuid_major == major}) {
           return seller
        } else {
           return nil
        }
    }
}
