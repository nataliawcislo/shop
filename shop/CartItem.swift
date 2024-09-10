//
//  CartItem.swift
//  shop
//
//  Created by Natalia on 10.09.24.
//

import Foundation
import SwiftUI

struct CartItem: Identifiable, Equatable {
    let id = UUID()
    let product: Product
    var quantity: Int
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.id == rhs.id
    }
}
