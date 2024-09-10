//
//  CartView.swift
//  shop
//
//  Created by Natalia on 10.09.24.
//

import SwiftUI
import StoreKit
import PassKit

import SwiftUI
import StoreKit
import PassKit

struct CartView: View {
    @Binding var cartItems: [CartItem]
    @StateObject private var storeKitManager = StoreKitManager.shared
    @State private var totalAmount: Double = 0.0

    var body: some View {
        VStack {
            List {
                ForEach(cartItems) { cartItem in
                    HStack {
                        Image(cartItem.product.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(cartItem.product.name)
                                .font(.headline)
                            Text(String(format: "$%.2f", cartItem.product.price))
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                updateQuantity(of: cartItem.product, by: -1)
                            }) {
                                Text("-")
                                    .frame(width: 30, height: 30)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(15)
                                    .padding(.trailing, 5)
                            }
                            .disabled(cartItem.quantity <= 1)

                            Text("\(cartItem.quantity)")
                                .frame(width: 50, height: 30)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(15)
                                .padding(.horizontal, 5)
                            
                            Button(action: {
                                updateQuantity(of: cartItem.product, by: 1)
                            }) {
                                Text("+")
                                    .frame(width: 30, height: 30)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .padding(.leading, 5)
                            }
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            removeFromCart(cartItem.product)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .onChange(of: cartItems) { _ in
                calculateTotalAmount()
            }
            .onAppear {
                calculateTotalAmount()
            }
            
            Text("Total: $\(totalAmount, specifier: "%.2f")")
                .font(.title2)
                .padding()
            
            Button(action: proceedToCheckout) {
                Text("Checkout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            // Apple Pay Button
            if PKPaymentAuthorizationController.canMakePayments() {
                Button(action: payWithApplePay) {
                    Text("Pay with Apple Pay")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationTitle("Cart")
        .alert(isPresented: $storeKitManager.showingAlert) {
            Alert(title: Text(storeKitManager.alertMessage))
        }
    }

    private func updateQuantity(of product: Product, by amount: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            let newQuantity = cartItems[index].quantity + amount
            if newQuantity <= 0 {
                removeFromCart(product)
            } else {
                cartItems[index].quantity = newQuantity
                calculateTotalAmount()
            }
        }
    }

    private func removeFromCart(_ product: Product) {
        cartItems.removeAll { $0.product.id == product.id }
        calculateTotalAmount()
    }

    private func calculateTotalAmount() {
        totalAmount = cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }

    private func proceedToCheckout() {
        let totalProducts = cartItems.reduce(0) { $0 + $1.quantity }
        print("Proceed to Checkout Button Pressed")
        print("Cart Items: \(cartItems)")
        print("Total number of products: \(totalProducts)")
        
        storeKitManager.purchaseProducts(cartItems: cartItems) { success in
            if success {
                // Handle successful purchase
                print("Purchase was successful!")
            } else {
                // Handle failed purchase
                print("Purchase failed.")
            }
        }
    }
    
    private func payWithApplePay() {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "your.merchant.identifier" // Replace with your valid merchant identifier
        paymentRequest.supportedNetworks = [.visa, .masterCard, .amex] // Add other supported networks if needed
        paymentRequest.countryCode = "US" // Replace with your country code
        paymentRequest.currencyCode = "USD" // Replace with your currency code
        
        // Payment summary items (ensure valid product details)
        paymentRequest.paymentSummaryItems = cartItems.map { item in
            PKPaymentSummaryItem(label: item.product.name, amount: NSDecimalNumber(decimal: Decimal(item.product.price * Double(item.quantity))))
        }
        
        // Check if Apple Pay is available and present the controller
        let paymentAuthorizationController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentAuthorizationController.delegate = Coordinator(parent: self)
        
        // Present the Apple Pay authorization sheet
        paymentAuthorizationController.present { (presented) in
            if presented {
                print("Payment authorization was presented successfully.")
            } else {
                print("Failed to present payment authorization.") // Error appears here if there's a problem
            }
        }
    }
}


extension CartView {
    class Coordinator: NSObject, PKPaymentAuthorizationControllerDelegate {
        var parent: CartView
        
        init(parent: CartView) {
            self.parent = parent
        }
        
        func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
            // Handle successful authorization
            print("Payment authorized with token: \(payment.token)")
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
        
        func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
            // Dismiss the payment controller
            print("Payment authorization controller did finish.")
            controller.dismiss(completion: nil)
        }
    }
}
