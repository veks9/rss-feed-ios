//
//  FeedCell.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit
import SnapKit

final class FeedCell: UITableViewCell {

    // MARK: - Views
    
    private lazy var feedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.image = Assets.rssPlaceholder.image
        
        return imageView
    }()
    
    private let verticalStackContainerView = UIView()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.set(textColor: .black, font: .systemFont(ofSize: 18, weight: .bold))
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true

        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.set(textColor: .gray, font: .systemFont(ofSize: 12, weight: .regular))
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var trailingIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.chevronRight.systemImage
        imageView.tintColor = .black
        
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        styleCell()
        addSubviews()
        setConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedImageView.image = Assets.rssPlaceholder.image
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func styleCell() {
        selectionStyle = .none
        backgroundColor = .white
    }

    private func addSubviews() {
        contentView.addSubview(feedImageView)
        contentView.addSubview(verticalStackContainerView)
        contentView.addSubview(trailingIconImageView)
        
        verticalStackContainerView.addSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(descriptionLabel)
    }

    private func setConstraints() {
        feedImageView.snp.remakeConstraints {
            $0.top.greaterThanOrEqualToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.lessThanOrEqualToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(feedImageView.snp.width).multipliedBy(0.625)
        }
        
        verticalStackContainerView.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalTo(feedImageView.snp.trailing).offset(8)
        }
        
        verticalStackView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
        
        trailingIconImageView.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(verticalStackContainerView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-22)
            $0.height.equalTo(20)
            $0.width.equalTo(15)
        }
    }
}

// MARK: - Internal functions

extension FeedCell {
    func updateUI(viewModel: FeedCellViewModel) {
        feedImageView.setImage(viewModel.imageUrl, placeholder: Assets.rssPlaceholder.image)
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
    }
}
