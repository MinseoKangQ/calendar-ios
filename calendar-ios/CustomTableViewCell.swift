//
//  CustomTableViewCell.swift
//  calendar-ios
//
//  Created by 강민서 on 6/8/24.
//

import UIKit
import M13Checkbox

class CustomTableViewCell: UITableViewCell {
    
    var checkbox: M13Checkbox!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        setupViews()
//        setupConstraints()
    }
    
    private func setupViews() {

        checkbox = M13Checkbox()
        contentView.addSubview(checkbox)
        
        // Initialize the labels
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        contentView.addSubview(titleLabel)
        
        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.textColor = .gray
        contentView.addSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Checkbox constraints
            checkbox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: checkbox.leadingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            // Subtitle label constraints
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: checkbox.leadingAnchor, constant: -10),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
