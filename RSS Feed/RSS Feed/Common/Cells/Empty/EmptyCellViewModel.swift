//
//  EmptyCellViewModel.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

final class EmptyCellViewModel {
    let id: String
    let image: UIImage?
    let descriptionText: String?

    init(
        id: String,
        image: UIImage?,
        descriptionText: String?
    ) {
        self.id = id
        self.image = image
        self.descriptionText = descriptionText
    }
}
