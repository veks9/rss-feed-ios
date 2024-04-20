//
//  FeedItemCell.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 20.04.2024..
//

import UIKit
import SnapKit

final class FeedItemCell: UITableViewCell {

    // MARK: - Views
    
    private lazy var feedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
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
        label.set(textColor: .black, font: .systemFont(ofSize: 20, weight: .bold))
        label.numberOfLines = 2

        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.set(textColor: .darkGray, font: .systemFont(ofSize: 14, weight: .regular))
        label.numberOfLines = 0
        
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        styleCell()
        addSubviews()
        setConstraints()
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
        
        verticalStackContainerView.addSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(descriptionLabel)
    }

    private func setConstraints() {
        feedImageView.snp.remakeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(200)
        }
        
        verticalStackContainerView.snp.remakeConstraints {
            $0.top.equalTo(feedImageView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        verticalStackView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Internal functions

extension FeedItemCell {
    func updateUI(viewModel: FeedItemCellViewModel) {
        feedImageView.setImage(viewModel.imageUrl, placeholder: Assets.rssPlaceholder.image)
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
    }
}
