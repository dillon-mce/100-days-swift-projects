//
//  DetailViewController.swift
//  Day50Challenge
//
//  Created by Dillon McElhinney on 7/9/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class DetailViewController: ShiftableViewController {
    var photo: Photo?
    var saveHandler: (() -> Void)?
    
    private var imageView: UIImageView!
    private var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .save,
                            target: self,
                            action: #selector(savePhoto))
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.constrainToSuperView(view,
                                       top: 8,
                                       leading: 8,
                                       trailing: 8)
        imageView.constrain(aspectWidth: 1)
        
        textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Your caption"
        textField.constrainToSuperView(view,
                                       leading: 20,
                                       trailing: 20)
        textField.constrainToSiblingView(imageView,
                                         below: 20)
        
        updateViews()
    }
    
    private func updateViews() {
        guard isViewLoaded, imageView != nil else { return }
        guard let photo = photo else { return }
        
        let filePath = URL.documentPath(for: photo.fileName).path
        imageView.image = UIImage(contentsOfFile: filePath)
        
        textField.text = photo.caption
    }
    
    @objc private func savePhoto() {
        guard let caption = textField.text else { return }
        
        photo?.caption = caption
        
        if let saveHandler = saveHandler { saveHandler() }
        navigationController?.popViewController(animated: true)
    }
}
