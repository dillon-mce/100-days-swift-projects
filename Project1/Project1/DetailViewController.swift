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

        assert(selectedImage != nil, "We should never be on this view without an image.")

        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
        
//        title = selectedImage
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
