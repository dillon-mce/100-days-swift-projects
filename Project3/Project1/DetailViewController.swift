//
//  DetailViewController.swift
//  Project1
//
//  Created by Dillon McElhinney on 5/29/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var selectedImage: String?
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
        
        navigationItem.largeTitleDisplayMode = .never
        let barButton = UIBarButtonItem(barButtonSystemItem: .action,
                                        target: self,
                                        action: #selector(shareImage))
        navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareImage() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8),
        let imageName = selectedImage else {
            print("No image found.")
            return
        }
        let activityVC = UIActivityViewController(activityItems: [image, imageName],
                                                              applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem =
            navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }

}
