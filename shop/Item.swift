//
//  Item.swift
//  shop
//
//  Created by Natalia on 10.09.24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
