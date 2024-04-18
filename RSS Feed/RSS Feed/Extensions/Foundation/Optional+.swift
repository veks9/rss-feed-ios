//
//  Optional+.swift
//  helute
//
//  Created by Vedran Hernaus on 14.03.2024..
//

import Foundation

extension Optional where Wrapped == String {
    var isEmptyOrNil: Bool {
        if let unwrapped = self {
            return unwrapped.isBlank
        } else {
            return true
        }
    }
}

extension Optional where Wrapped == Bool {
    var isNilOrFalse: Bool {
        !(self ?? false)
    }
}

extension Optional where Wrapped == [String: String] {
    var isEmptyOrNil: Bool {
        if let dictionary = self {
            return dictionary.isEmpty
        } else {
            return true
        }
    }
}

extension Optional where Wrapped == [String: String?] {
    var isEmptyOrNil: Bool {
        if let dictionary = self {
            return dictionary.isEmpty
        } else {
            return true
        }
    }
}

extension Optional where Wrapped == String {
    func toURL() -> URL? {
        guard let url = self else { return nil }
        return url.toURL()
    }
}

extension Optional where Wrapped == String {
    func toInt() -> Int? {
        guard let value = self else { return nil }
        return Int(value)
    }
}
