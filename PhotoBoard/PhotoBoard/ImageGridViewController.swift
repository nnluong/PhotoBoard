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
        guard let newUrl = URL(string: "\(imageBaseUrlString)?random=\(UUID().uuidString)") else { return }
        
        imageUrls.append(newUrl)
        
        let newIndexPath = IndexPath(item: imageUrls.count - 1, section: 0)
        collectionView.insertItems(at: [newIndexPath])
        
        let page = floor(CGFloat(newIndexPath.item) / 70.0)
        let newOffset = CGPoint(x: page * collectionView.bounds.width, y: 0)
        collectionView.setContentOffset(newOffset, animated: true)
    }
    
    @objc private func reloadAllTapped() {
        reloadAllImages()
    }
    
    private func reloadAllImages() {
        // Clear existing data and cache
        imageUrls.removeAll()
        imageCache.removeAllObjects()
                
        // Generate 140 new unique image URLs
        for _ in 0..<140 {
            if let url = URL(string: "\(imageBaseUrlString)?random=\(UUID().uuidString)") {
            imageUrls.append(url)
            }
        }
                
        // Refresh the collection view on the main thread
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.setContentOffset(.zero, animated: false)
        }
        
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
        
        let imageUrl = imageUrls[indexPath.item]
        
        // Check cache first
         if let cachedImage = imageCache.object(forKey: imageUrl as NSURL) {
             cell.configure(with: cachedImage)
         } else {
             // If not in cache, start download
             cell.configure(with: nil) // Show activity indicator
             downloadImage(from: imageUrl) { [weak self] image in
                 guard let self = self, let image = image else { return }
                 
                 // Cache the downloaded image
                 self.imageCache.setObject(image, forKey: imageUrl as NSURL)
                 
                 // Update the cell only if it's still visible and meant for this indexPath
                 if let visibleCell = self.collectionView.cellForItem(at: indexPath) as? ImageCell {
                     visibleCell.configure(with: image)
                 }
             }
         }
        
        return cell
    }

    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
