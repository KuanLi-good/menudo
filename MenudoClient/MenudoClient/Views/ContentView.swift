import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var cartManager = CartManager()
    @AppStorage("sellerId") var sellerId: String = ""
    @AppStorage("restaurant_name") var restaurant_name: String = ""
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    @ObservedObject var productList = ProductList()
    
    init(){
        get_inventory()

//        dump(productList)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(productList.products, id: \.id) { product in
                        ProductCard(product: product)
                            .environmentObject(cartManager)
                            .environmentObject(productList)
                    }
                }
                .padding()
            }
            .navigationTitle(Text(self.restaurant_name.isEmpty ? "Restaurant Name" : self.restaurant_name))
            .toolbar {
                HStack {
                Button("Exit") {
                        self.sellerId = ""
                        print("Exit tapped!")
                }
            
                NavigationLink {
                    CartView()
                        .environmentObject(cartManager)
                } label: {
                    CartButton(numberOfProducts: cartManager.products.count)
                }
            }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func get_inventory(){
        Serverless.shared.get_inventory(userId: sellerId) { [self] result in
            switch result {
            case .success(let inventory) :
                productList.set(list: inventory)
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

