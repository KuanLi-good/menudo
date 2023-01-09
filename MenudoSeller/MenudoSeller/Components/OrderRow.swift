//
//  OrderRow.swift
//  MenudoAdmin
//
//  Created by kuan on 5/11/22.
//

import SwiftUI

struct OrderRow: View {
    var order: Order
    var index: Int
    @State var isExpanded = false
    @EnvironmentObject var orderList: OrderList
    
    init(order: Order, index: Int) {
        self.order = order
        self.index = index
        print(index)
        dump(order)
    }
    var body: some View {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    ForEach(order.items, id: \.self) {
                        item in
                        Text("\(item)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button("Complete") {
                        Serverless.shared.complete_order(with: order.id) { [self] result in
                            switch result {
                            case .success(_) :
                                orderList.complete(order: order)
                                break
                            case .failure(let error):
                                print(error.localizedDescription)
                                break
                            }
                        }
                    }.tint(.green)
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                },
                label: { Text("ID: \(String(order.id.suffix(4)))   AU$\(order.total_price, specifier: "%.2f")") })
    }
}

