//
//  ContentView.swift
//  shop
//
//  Created by Natalia on 10.09.24.
//

import SwiftUI
import SwiftUI

struct ContentView: View {
    @State private var cartItems: [CartItem] = []

    var body: some View {
        NavigationView {
            ProductListView(products: sampleProducts, addToCart: addToCart, cartItems: $cartItems)
        }
    }

    private func addToCart(product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            // Update quantity if the product is already in the cart
            cartItems[index].quantity += 1
        } else {
            // Add new item to the cart
            let newCartItem = CartItem(product: product, quantity: 1)
            cartItems.append(newCartItem)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
