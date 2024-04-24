//
//  EmptyCell.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit
import SnapKit

final class EmptyCell: UITableViewCell {

    // MARK: - Views

    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 2

        return stackView
    }()

    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        
        return imageView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    // MARK: - Lifecycle
    
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
    
    // MARK: - Private functions

    private func styleCell() {
        selectionStyle = .none
        backgroundColor = .white
    }

    private func addSubviews() {
        contentView.addSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(emptyImageView)
        verticalStackView.addArrangedSubview(descriptionLabel)
    }

    private func setConstraints() {
        verticalStackView.snp.remakeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        emptyImageView.snp.remakeConstraints {
            $0.width.height.equalTo(60)
        }
    }
}

// MARK: - Internal functions

extension EmptyCell {
    func updateUI(viewModel: EmptyCellViewModel) {
        emptyImageView.image = viewModel.image
        emptyImageView.isHidden = viewModel.image == nil
        descriptionLabel.text = viewModel.descriptionText
    }
}
