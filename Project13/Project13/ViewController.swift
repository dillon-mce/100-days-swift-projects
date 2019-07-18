//
//  ViewController.swift
//  Project13
//
//  Created by Dillon McElhinney on 7/11/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController,
                      UINavigationControllerDelegate,
                      UIImagePickerControllerDelegate {

    @IBOutlet var controlStackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var filterButton: UIButton!
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter! {
        didSet {
            if let title = currentFilter.attributes[kCIAttributeFilterDisplayName] as? String {
                filterButton.setTitle(title, for: .normal)
            }
        }
    }
    
    private var sliders: [FilterInputSlider] = []
    private let filters = ["CIBumpDistortion",
                   "CIGaussianBlur",
                   "CIPixellate",
                   "CISepiaTone",
                   "CITwirlDistortion",
                   "CIUnsharpMask",
                   "CIVignette",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose Filter",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        for filter in filters {
            let action = UIAlertAction(title: filter,
                                       style: .default,
                                       handler: setFilter)
            alertController.addAction(action)
        }

        alertController.add("Cancel")
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }

    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else {
            presentErrorAlert(title: "No Photo",
                              message: "You can't save a photo that doesn't exist.")
            return
        }

        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage,
                               forKey: kCIInputImageKey)
        
        applyProcessing()
        
        dismiss(animated: true) {
            UIView.animate(withDuration: 0.5) {
                self.imageView.alpha = 1
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageView.alpha = 1
        dismiss(animated: true)
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        UIView.animate(withDuration: 0.1) {
            self.imageView.alpha = 0
        }
        present(picker, animated: true)
    }
    
    @objc func applyProcessing() {
        guard let image = currentFilter.outputImage else { return }
        
        if currentFilter.inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2,
                                            y: currentImage.size.height / 2),
                                   forKey: kCIInputCenterKey)
        }
        
        for sliderAttribute in sliders {
            let value = sliderAttribute.slider.value
            currentFilter.setValue(value,
                                   forKey: sliderAttribute.attributeName)
        }
        
        if let cgimg = context.createCGImage(image,
                                             from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else {
            presentErrorAlert(title: "No Photo",
                              message: "You have to pick a photo before you set the filter.")
            return
        }
        
        guard let actionTitle = action.title else { return }
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage,
                               forKey: kCIInputImageKey)
        buildSliders()

        applyProcessing()
    }
    
    private func buildSliders() {
        for slider in sliders {
            controlStackView.removeArrangedSubview(slider.view)
            slider.view.removeFromSuperview()
        }
        
        guard let currentFilter = currentFilter else { return }
        sliders = currentFilter.attributes
            .compactMap { FilterInputSlider(name: $0, attributes: $1) }
            .sorted { $0.displayName > $1.displayName }
        
        let layoutGuide = UILayoutGuide()
        view.addLayoutGuide(layoutGuide)
        
        for (_, sliderInput) in sliders.enumerated() {
            controlStackView.insertArrangedSubview(sliderInput.view, at: 0)
            
            let slider = sliderInput.slider
            
            let equalWidth = slider.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor)
            equalWidth.isActive = true
            
            slider.addTarget(self, action: #selector(applyProcessing), for: .valueChanged)
        }
    }
    
    @objc func image(_ image: UIImage,
                     didFinishSavingWithError error: Error?,
                     contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            presentErrorAlert(title: "Save Error",
                              message: error.localizedDescription)
        } else {
            let alertController = UIAlertController(title: "Saved!",
                                                    message: "Your altered image has been saved to your photos.",
                                                    preferredStyle: .alert)
            alertController.add("Ok",
                                style: .default)
            present(alertController,
                    animated: true)
        }
    }
    
    func presentErrorAlert(title: String?, message: String? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.add("Ok",
                            style: .default)
        present(alertController,
                animated: true)
    }
}

extension UIAlertController {
    func add(_ title: String,
             style: UIAlertAction.Style = .cancel) {
        let action = UIAlertAction(title: title,
                                         style: style)
        self.addAction(action)
    }
}
