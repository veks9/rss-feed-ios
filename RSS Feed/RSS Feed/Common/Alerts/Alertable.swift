//
//  Alertable.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

protocol Alertable {
    func presentAlert(alertViewModel: AlertViewModel)
}

extension Alertable {
    func presentAlert(alertViewModel: AlertViewModel) {
        let alertController = UIAlertController(
            title: alertViewModel.title,
            message: alertViewModel.message,
            preferredStyle: alertViewModel.preferredSyle
        )
        
        alertViewModel.actions.forEach { alertActionViewModel in
            let action = UIAlertAction(
                title: NSLocalizedString(alertActionViewModel.title, comment: ""),
                style: alertActionViewModel.style
            ) { _ in
                alertActionViewModel.action?()
            }
            alertController.addAction(action)
        }

        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
}
