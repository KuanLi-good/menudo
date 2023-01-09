import Foundation

struct Product: Identifiable {
    var id: String
    var seller: String
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
    
    
    init(id: String, name: String, image: String, seller: String, price: Double) {
        self.id = id
        self.name = name
        self.seller = seller
        self.price = price
        self.image = image
    }

}

class ProductList: ObservableObject {
    @Published private(set) var products: [Product] = []
    
    func set(list: [Product]) {
        products.removeAll()
        products.append(contentsOf: list)
    }
    
}
