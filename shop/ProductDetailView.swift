//
//  ProductDetailView.swift
//  shop
//
//  Created by Natalia on 10.09.24.
//
import SwiftUI

struct ProductDetailView: View {
    let product: Product?
    var addToCart: (Product) -> Void
    @Binding var cartItems: [CartItem] // Correctly use Binding

    @State private var isInCart = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            if let product = product {
                Image(product.image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .clipped()
                    .padding(.bottom, 20)

                Text(product.name)
                    .font(.title)
                    .padding(.bottom, 2)

                Text(String(format: "$%.2f", product.price))
                    .font(.title2)
                    .foregroundColor(.green)
                    .padding(.bottom, 2)

                Text(product.productDescription)
                    .font(.body)
                    .padding(.bottom, 20)

                HStack {
                    Spacer()
                    Button(action: addProductToCart) {
                        Text(isInCart ? "Added to Cart" : "Add to Cart")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isInCart ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    Spacer()
                }
                .padding(.bottom, 20)

                Spacer()
            } else {
                Text("Product not found")
                    .font(.title)
                    .padding()
            }
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if let product = product {
                isInCart = cartItems.contains(where: { $0.product.id == product.id })
            }
        }
    }

    private func addProductToCart() {
        if let product = product, !isInCart {
            addToCart(product)
            isInCart = true
            dismiss() // Navigate back to the previous view
        }
    }
}
