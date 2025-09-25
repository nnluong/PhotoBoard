//
//  ImageCell.swift
//  PhotoBoard


import Foundation
import UIKit

class ImageCell: UICollectionViewCell {
    static let reuseIdentifier = "ImageCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 7
        iv.backgroundColor = .secondarySystemBackground // Placeholder color
        return iv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([ imageView.topAnchor.constraint(equalTo: contentView.topAnchor), imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor), imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor), imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor), activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor), activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Resets cell for reuse.
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicator.stopAnimating()
    }
    
    func configure(with image: UIImage?) {
        if let image = image {
            imageView.image = image
            activityIndicator.stopAnimating()
        } else {
            imageView.image = nil
            activityIndicator.startAnimating()
        }
    }
}
