//
//  StoreKitManager.swift
//  shop
//
//  Created by Natalia on 10.09.24.
//
import Foundation
import StoreKit
import Combine

import Foundation
import StoreKit
import Combine

class StoreKitManager: NSObject, ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var products: [SKProduct] = []
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    private var productRequest: SKProductsRequest?
    private var purchaseCompletion: ((Bool) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    override private init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func fetchProducts(productIDs: Set<String>) {
        productRequest?.cancel()
        productRequest = SKProductsRequest(productIdentifiers: productIDs)
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    func purchaseProducts(cartItems: [CartItem], completion: @escaping (Bool) -> Void) {
        guard !cartItems.isEmpty else {
            completion(false)
            return
        }
        
        purchaseCompletion = completion
        
        let productIdentifiers = Set(cartItems.map { $0.product.id })
        fetchProducts(productIDs: productIdentifiers)
        
        // Wait for products to be fetched, then attempt to purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            for cartItem in cartItems {
                if let product = self.products.first(where: { $0.productIdentifier == cartItem.product.id }) {
                    self.handlePurchase(for: product)
                }
            }
        }
    }
    
    private func handlePurchase(for product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    private func completePurchase(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        alertMessage = "Purchase successful!"
        showingAlert = true
        purchaseCompletion?(true)
    }
    
    private func failPurchase(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        alertMessage = "Purchase failed. Please try again."
        showingAlert = true
        purchaseCompletion?(false)
    }
}

// MARK: - SKProductsRequestDelegate
extension StoreKitManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            let validProducts = response.products
            let invalidProductIdentifiers = response.invalidProductIdentifiers
            
            if !invalidProductIdentifiers.isEmpty {
                self.alertMessage = "Invalid product identifiers: \(invalidProductIdentifiers.joined(separator: ", "))"
                self.showingAlert = true
            }
            
            self.products = validProducts
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.alertMessage = "Failed to fetch products: \(error.localizedDescription)"
            self.showingAlert = true
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension StoreKitManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completePurchase(transaction)
            case .failed:
                failPurchase(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // Handle restore completed transactions if needed
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            self.alertMessage = "Failed to restore purchases: \(error.localizedDescription)"
            self.showingAlert = true
        }
    }
}
