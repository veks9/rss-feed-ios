//
//  Double+.swift
//  helute
//
//  Created by Vedran Hernaus on 14.03.2024..
//

import Foundation

extension Double {
    func toString() -> String {
        String(self)
    }

    func toInt() -> Int? {
        if self >= Double(Int.min), self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }

    func toPercent() -> String? {
        if let intValue = (self * 100).toInt() {
            return intValue.toString().appending("%")
        } else {
            return nil
        }
    }
}
