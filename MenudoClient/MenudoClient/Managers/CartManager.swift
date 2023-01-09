import Foundation
import SwiftUI

class CartManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var total: Double = 0
    
    // Payment-related variables
    let paymentHandler = PaymentHandler()
    @Published var paymentSuccess = false
    
    
    // Functions to add and remove from cart
    func addToCart(product: Product) {
        products.append(product)
        total += product.price
    }
    
    func removeFromCart(index: Int) {
        let product = products.remove(at: index)
        total -= product.price
    }
    
    // Call the startPayment function from the PaymentHandler. In the completion handler, set the paymentSuccess variable
    func pay() {
        self.send_order()
        paymentHandler.startPayment(products: products, total: total) { success in
            self.paymentSuccess = success
            self.products = []
            self.total = 0
        }
    }
    
    
    func send_order(){
        var items: [String] = []
        for item in products {
            items.append(item.name)
        }
        
        Serverless.shared.send_order(with: Order(items: items, total_price: self.total)) { [self] result in
            switch result {
            case .success(_) :
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
}
