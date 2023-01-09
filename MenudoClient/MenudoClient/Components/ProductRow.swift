import SwiftUI

struct ProductRow: View {
    @EnvironmentObject var cartManager: CartManager
    var product: Product
    var index: Int
    
    var body: some View {
        HStack(spacing: 20) {
            AsyncImage(url: URL(string: product.image)) { image in
                            image.resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
                .progressViewStyle(.circular)
            }
            .frame(width: 50)
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(product.name)
                    .bold()

                Text("$\(product.price, specifier: "%.2f")")
            }
            
            Spacer()

            Image(systemName: "trash")
                .foregroundColor(Color(hue: 1.0, saturation: 0.89, brightness: 0.835))
                .onTapGesture {
                    cartManager.removeFromCart(index: index)
                }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
