import SwiftUI

struct ProductCard: View {
    @EnvironmentObject var productList: ProductList
    @State private var showingAlert = false
    @State private var inProgress = false
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
                    
                    if (inProgress) {
                        ProgressView("Deleting...")
                        .progressViewStyle(.circular)
                    }
                }
                .padding()
                .frame(width: 168, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            .frame(width: 170, height: 170)
            .shadow(radius: 3)
            
            Button {
                showingAlert = true
            } label: {
                Image(systemName: "trash.square")
                    .font(.system(size: 30))
                    .shadow(radius: 5)
                    .padding()
                
            }
            .alert("Are you sure to delete?", isPresented: $showingAlert) {
                Button("Yes") {
                    inProgress = true
                    // connect to backend
                    Serverless.shared.delete_item(with: product.id) { [self] result in
                        switch result {
                        case .success(_) :
                            inProgress = false
                            productList.remove(product: product)
                            break
                        case .failure(let error):
                            inProgress = false
                            print(error.localizedDescription)
                            break
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}
