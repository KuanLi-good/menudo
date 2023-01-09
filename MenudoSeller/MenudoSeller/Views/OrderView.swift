import SwiftUI

struct OrderView: View {
    @EnvironmentObject var orderList: OrderList
    
    var body: some View {
        ScrollView {
            if orderList.orders.count > 0 {
                ForEach(Array(orderList.orders.enumerated()), id: \.offset) { index, element in
                    OrderRow(order: element, index: index)
                        .environmentObject(orderList)
                }
            }else {
                Text("Your don't have any order.")
            }
        }
        .navigationTitle(Text("Orders"))
        .padding(.top)
    }
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView()
    }
}

