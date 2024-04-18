//
//  UIImage+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import Kingfisher
import UIKit

extension UIImageView {
    func setImage(_ urlString: String?, options: KingfisherOptionsInfo? = nil) {
        guard let urlString = urlString else { return }
        startKFIndicator()
        kf.setImage(with: urlString.toURL(), options: options)
    }

    func setImage(_ url: URL?, spinnerViewColor: UIColor = .black) {
        guard let url = url else { return }
        startKFIndicator()
        kf.setImage(with: url)
    }

    private func startKFIndicator(spinnerViewColor: UIColor = .black) {
        kf.indicatorType = .activity
        (kf.indicator?.view as? UIActivityIndicatorView)?.color = spinnerViewColor
    }
}
