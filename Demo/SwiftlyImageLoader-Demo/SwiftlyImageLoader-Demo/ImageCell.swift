//
//  ImageCell.swift
//  SwiftlyImageLoader-Demo
//
//  Created by Mohsin Khan on 02/04/25.
//

import UIKit
import SwiftlyImageLoader

class ImageCell: UITableViewCell {
    static let reuseId = "ImageCell"
    let customImageView = UIImageView()
    var currentImageUrl: URL?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        customImageView.contentMode = .scaleAspectFill
        customImageView.clipsToBounds = true
        contentView.addSubview(customImageView)

        NSLayoutConstraint.activate([
            customImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            customImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.cancelImageLoad(for: currentImageUrl)
    }
}
