//
//  String+.swift
//  helute
//
//  Created by Vedran Hernaus on 14.03.2024..
//

import UIKit

extension String {
    func toURL() -> URL? {
        URL(string: self)
    }
}

extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }

    func isValidID(startNumber: Int, endNumber: Int) -> Bool {
        let range = startNumber...endNumber
        return range.contains(count) ? true : false
    }

    func isValidUsername() -> Bool {
        let usernameRegex = "[a-z0-9][a-z0-9.]{4,23}"

        let usernamePred = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return usernamePred.evaluate(with: self)
    }

    func isValidFullName() -> Bool {
        let fullNameRegex = "^[\\p{L}0-9'\\-\\_\\. ]{1,100}"
        let fullNamePred = NSPredicate(format: "SELF MATCHES %@", fullNameRegex)
        
        return fullNamePred.evaluate(with: self)
    }
    
    func isValidName() -> Bool {
        let firstNameRegex = "^[\\p{L}]{1,50}$"
        return NSPredicate(format: "SELF MATCHES %@", firstNameRegex).evaluate(with: self)
    }
    
    func isValidDate(dateFormatter: DateFormatter) -> Bool {
        if let date = dateFormatter.date(from: self) {
            let formattedDateString = dateFormatter.string(from: date)
            return self == formattedDateString
        } else {
            return false
        }
    }

    func isValidPassword() -> Bool {
        let passwordRegex = "(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

        return passwordPred.evaluate(with: self)
    }

    func toAttributedString(highlightedText: String, font: UIFont) -> AttributedString {
        var attributedString = AttributedString(self)
        if let range = attributedString.range(of: highlightedText) {
            attributedString[range].font = font
        }
        return attributedString
    }
}

extension String {
    func getUnerlinedAttributedString() -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: self)
        guard let rangeIndex = self.range(of: self) else { return nil }
        let range = NSRange(rangeIndex, in: attributedString.string)
        attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue], range: range)

        return attributedString
    }
}

extension String {
    func toDouble() -> Double? {
        Double(self)
    }
    
    func toInt() -> Int? {
        Int(self)
    }
}

extension String {
    func toDictionary() -> [String: AnyObject]? {
       if let data = self.data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
               return json
           } catch {
               print("Something went wrong")
           }
       }
       return nil
   }
}

extension String {
    func contains(insensitive other: String, locale: Locale? = nil) -> Bool {
        range(of: other, options: [.diacriticInsensitive, .caseInsensitive], locale: locale) != nil
    }

    func addAttributes(_ attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString? {
        let attributedString = NSMutableAttributedString(string: self)
        guard let rangeIndex = self.range(of: self) else { return nil }
        let range = NSRange(rangeIndex, in: attributedString.string)
        attributedString.addAttributes(attributes, range: range)

        return attributedString
    }
}
