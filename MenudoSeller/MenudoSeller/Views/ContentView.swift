import SwiftUI

struct ContentView: View {
    
    @ObservedObject var broadcast = BeaconBroadcast()
    @ObservedObject var productList = ProductList()
    @ObservedObject var orderList = OrderList()
    @AppStorage("restaurant_name") var restaurant_name: String = ""
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    
    init(){
        broadcast.initLocalBeacon()
        get_inventory()
        get_orders()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(productList.products, id: \.id) { product in
                        ProductCard(product: product)
                            .environmentObject(productList)
                    }
                }
                .padding()
            }
            .navigationTitle(Text(self.restaurant_name.isEmpty ? "Restaurant Name" : self.restaurant_name))
            .toolbar {
                HStack {
                NavigationLink {
                    AddItemView()
                        .environmentObject(productList)
                } label: {
                    Image(systemName: "plus.app")
                }
                NavigationLink {
                    OrderView()
                        .environmentObject(orderList)
                        .onAppear(perform: {
                                    get_orders()
                                })
                        .onDisappear(perform: {
                                    get_orders()
                                })
                } label: {
                    OrderButton(numberOfProducts: orderList.orders.count)
                }
                NavigationLink {
                    ProfileView()
                } label: {
                    Image(systemName: "person.circle")
                }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func get_inventory(){
        Serverless.shared.get_inventory { [self] result in
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
    
    func get_orders(){
        Serverless.shared.get_orders { [self] result in
            switch result {
            case .success(let orders) :
                orderList.set(list: orders)
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
