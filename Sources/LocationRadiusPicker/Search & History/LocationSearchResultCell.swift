//
//  LocationSearchResultCell.swift
//
//
//  Created by Eman Basic on 28.09.24.
//

import UIKit

final class LocationSearchResultCell: UITableViewCell {
    
    // MARK: - Views
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let locationTitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let locationValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 13)
        view.textColor = .label.withAlphaComponent(0.8)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [locationTitleLabel, locationValueLabel])
        view.axis = .vertical
        view.spacing = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }
}

// MARK: - Setup

extension LocationSearchResultCell {
    private func setup() {
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(labelsStackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            labelsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            labelsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            labelsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            labelsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Update

extension LocationSearchResultCell {
    func update(locationName: String, locationSubtitle: String) {
        locationTitleLabel.isHidden = locationName.isEmpty
        locationTitleLabel.text = locationName
        locationValueLabel.text = locationSubtitle
    }
}

// MARK: - Appearance

extension LocationSearchResultCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }

    override func setSelected(_ selected: Bool, animated: Bool) {
        UIView.transition(with: containerView, duration: 0.2, options: .transitionCrossDissolve) {
            self.containerView.backgroundColor = selected
                ? .label.withAlphaComponent(0.6)
                : .label.withAlphaComponent(0.1)
        }
    }
}
