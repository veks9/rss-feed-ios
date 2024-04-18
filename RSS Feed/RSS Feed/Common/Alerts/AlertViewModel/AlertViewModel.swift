//
//  AlertViewModel.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

struct AlertViewModel {
    let title: String?
    let message: String?
    let actions: [AlertActionViewModel]
    let preferredSyle: UIAlertController.Style

    init(
        title: String?,
        message: String?,
        actions: [AlertActionViewModel],
        preferredSyle: UIAlertController.Style = .alert
    ) {
        self.title = title
        self.message = message
        self.actions = actions
        self.preferredSyle = preferredSyle
    }
}
