import Foundation
import SwiftUI
struct Product: Identifiable {
    var id: String = UUID().uuidString
    @AppStorage("userId") var seller: String = ""
    var name: String
    var image: String
    var price: Double
    
    
    var toParams: [String: Any] {
            return [
                "id" : id as Any,
                "seller" : seller as Any,
                "name" : name as Any,
                "image" : image as Any,
                "price" : price as Any
            ]
    }
    
    
    init(name: String, price: Double) {
        self.name = name
        self.price = price
        self.image = ""
    }
    
    init(name: String, image: String, price: Double) {
        self.name = name
        self.price = price
        self.image = image
    }
    
    init(id: String, name: String, image: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
        self.image = image
    }
    
}

class ProductList: ObservableObject {
    @Published private(set) var products: [Product] = []
    
    func add(product: Product) {
        products.append(product)
    }
    
    func set(list: [Product]) {
        products.removeAll()
        products.append(contentsOf: list)
    }
    
    func remove(product: Product) {
        products = products.filter { $0.id != product.id }
    }
    
}
