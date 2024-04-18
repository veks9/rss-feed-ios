//
//  String+Localization.swift
//  helute
//
//  Created by Vedran Hernaus on 14.03.2024..
//

import Foundation

extension String {
    func localized(_ args: CVarArg...) -> String {
        guard !isEmpty else { return self }
        let localizedString = NSLocalizedString(self, comment: "")
        if args.isEmpty {
            return localizedString
        } else {
            return withVaList(args) { NSString(format: localizedString, locale: Locale.current, arguments: $0) as String }
        }
    }
}
