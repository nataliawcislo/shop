//
//  Product.swift
//  shop
//
//  Created by Natalia on 10.09.24.
//

import Foundation


struct Product: Identifiable {
    let id: String
    let name: String
    let image: String
    let productDescription: String
    let price: Double
}


let sampleProducts: [Product] = [
    Product(
        id: "com.yourapp.stylishshoes", // Replace with your actual product ID
        name: "Stylish Shoe",
        image: "shoes1", // Ensure this is the correct image name
        productDescription: "A very stylish and comfortable shoe.",
        price: 99.99
    ),
    Product(
        id: "com.yourapp.elegantjacket", // Replace with your actual product ID
        name: "Elegant Jacket",
        image: "shoes2",
        productDescription: "A sleek and elegant jacket for all occasions.",
        price: 149.99
    ),
    // Add more products here
]


// Sample cart items for demonstration
var sampleCartItems: [CartItem] {
    sampleProducts.map { CartItem(product: $0, quantity: 1) }
}
