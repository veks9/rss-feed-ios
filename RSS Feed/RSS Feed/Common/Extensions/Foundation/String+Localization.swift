//
//  String+Localization.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
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
