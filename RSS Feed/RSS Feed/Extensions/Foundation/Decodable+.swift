//
//  Decodable+.swift
//  helute
//
//  Created by Vedran Hernaus on 14.03.2024..
//

import Foundation

extension JSONDecoder {
    static let `default`: JSONDecoder = {
        let jsonDecoder = JSONDecoder()

        return jsonDecoder
    }()
}
