//
//  ImageGridViewController.swift
//  PhotoBoard

import Foundation
import UIKit

class ImageGridViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var imageUrls: [URL] = []
    private let imageCache = NSCache<NSURL, UIImage>()
    private let imageBaseUrlString = "https://picsum.photos/200/200"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Image Grid"
        
        // Setup navigation and collection view
        setupNavigationBar()
        setupCollectionView()
        
        // Load initial set of images
        reloadAllImages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureCollectionViewLayout()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImageTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reload All",
            style: .plain,
            target: self,
            action: #selector(reloadAllTapped)
        )
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
                
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
                
        // Enable pagination
        collectionView.isPagingEnabled = true
                
        // Register the custom cell class
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
                
        collectionView.dataSource = self
                
        view.addSubview(collectionView)
                
        // Layout constraints
        NSLayoutConstraint.activate([
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
    }
    
    private func configureCollectionViewLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let spacing: CGFloat = 2.0
        let numberOfColumns: CGFloat = 7.0
        let numberOfRows: CGFloat = 10.0
        
        let totalHorizontalSpacing = (numberOfColumns - 1) * spacing
        let itemWidth = floor((collectionView.bounds.width - totalHorizontalSpacing) / numberOfColumns)
        
        let totalVerticalSpacing = (numberOfRows - 1) * spacing
        let itemHeight = floor((collectionView.bounds.height - totalVerticalSpacing) / numberOfRows)
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = .zero
    }
    
    // MARK: - Actions
    @objc private func addImageTapped() {
    }
    
    @objc private func reloadAllTapped() {
        reloadAllImages()
    }
    
    private func reloadAllImages() {
        
    }
}

// MARK: - UICollectionViewDataSource

extension ImageGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: ImageCell.reuseIdentifier,
                   for: indexPath
               ) as? ImageCell else {
                   fatalError("Could not dequeue ImageCell")
               }
        
        return cell
    }
}
