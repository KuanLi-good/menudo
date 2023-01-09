import SwiftUI

struct ProductCard: View {
    @EnvironmentObject var cartManager: CartManager
    var product: Product
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: product.image)) { image in
                                image.resizable()
                                .scaledToFill()
                } placeholder: {
                    ProgressView()
                    .progressViewStyle(.circular)
                }
                .frame(width: 170, height: 170)
                .background(.white)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 2))
                .shadow(radius: 10)
                
                
                VStack(alignment: .leading) {
                    Text(product.name)
                        .bold()
                    
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.caption)
                }
                .padding()
                .frame(width: 168, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            .frame(width: 170, height: 170)
            .shadow(radius: 3)
            
            Button {
                cartManager.addToCart(product: product)
            } label: {
                Image(systemName: "plus")
                    .padding(10)
                    .foregroundColor(.white)
                    .background(.black)
                    .cornerRadius(50)
                    .padding()
            }
        }
    }
}

