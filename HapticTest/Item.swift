//
//  Item.swift
//  HapticTest
//
//  Created by Conner Yoon on 6/4/24.
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
