//
//  Item.swift
//  dnd_app
//
//  Created by Alexander Aferenok on 04.09.2025.
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
