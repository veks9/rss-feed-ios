//
//  AlertActionViewModel.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

struct AlertActionViewModel {
    let title: String
    let style: UIAlertAction.Style
    let action: (() -> Void)?

    init(
        title: String,
        style: UIAlertAction.Style = .default,
        action: (() -> Void)?
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
}
