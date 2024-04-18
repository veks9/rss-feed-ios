//
//  DateFormatter+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import Foundation

extension DateFormatter {
    /// dd.MM.yyyy.
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        
        return formatter
    }()
}
