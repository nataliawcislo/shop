//
//  ProductListView.swift
//  shop
//
//  Created by Natalia on 10.09.24.
//
import SwiftUI


struct ProductListView: View {
    let products: [Product]
    var addToCart: (Product) -> Void
    @Binding var cartItems: [CartItem]
    @State private var isShowingCart = false

    var body: some View {
        NavigationStack {
            VStack {
                List(products) { product in
                    NavigationLink(destination: ProductDetailView(product: product, addToCart: addToCart, cartItems: $cartItems)) {
                        HStack {
                            Image(product.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(product.name)
                                    .font(.headline)
                                Text(String(format: "$%.2f", product.price))
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }

                Button(action: {
                    isShowingCart = true
                }) {
                    Text("Go to Cart")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                NavigationLink(
                    destination: CartView(cartItems: $cartItems),
                    isActive: $isShowingCart
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Products")
        }
    }
}
