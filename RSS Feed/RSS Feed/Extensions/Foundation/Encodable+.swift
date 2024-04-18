//
//  Encodable+.swift
//  helute
//
//  Created by Vedran Hernaus on 14.03.2024..
//

import Foundation

extension Encodable {
    var data: Data? {
        try? JSONEncoder.default.encode(self)
    }

    var dictionaryOptional: [String: Any]? {
        guard let data = data else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension JSONEncoder {
    static let `default`: JSONEncoder = {
        let jsonEncoder = JSONEncoder()

        return jsonEncoder
    }()
}
