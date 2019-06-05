//
//  DetailViewController.swift
//  Day23 Challenge
//
//  Created by Dillon McElhinney on 6/5/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var countryName: String?

    @IBOutlet var flagImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    @objc private func shareFlag(action: UIAlertAction! = nil) {
        guard let imageName = countryName,
            let image = UIImage(named: imageName),
            let imageData = image.jpegData(compressionQuality: 0.8) else {
                return
        }
        
        let items: [Any] = [imageData, imageName]
        let activityVC =
            UIActivityViewController(activityItems: items,
                                     applicationActivities: [])
        
        activityVC.popoverPresentationController?.barButtonItem =
            navigationItem.rightBarButtonItem
        
        present(activityVC, animated: true)
        
    }

    private func setupViews() {
        guard let countryName = countryName else { return }
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .action,
                            target: self,
                            action: #selector(shareFlag))
        
        title = countryName.count < 3 ?
            countryName.uppercased() :
            countryName.capitalized
        
        flagImageView.image = UIImage(named: countryName)
        flagImageView.addBorder()
    }
}

extension UIView {
    func addBorder(width: CGFloat = 1, color: UIColor = .gray) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        
        self.layer.cornerRadius =
            min(self.frame.height, self.frame.width) / 24
        self.layer.masksToBounds = true
    }
}
