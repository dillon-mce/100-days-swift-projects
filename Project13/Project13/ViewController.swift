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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensitySlider: UISlider!
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
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

    @IBAction func changeFilter(_ sender: Any) {
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

        present(alertController, animated: true)
    }

    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else { return }

        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }

    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage,
                               forKey: kCIInputImageKey)

        applyProcessing()
        
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func applyProcessing() {
        guard let image = currentFilter.outputImage else { return }
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensitySlider.value,
                                   forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensitySlider.value * 200,
                                   forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensitySlider.value * 10,
                                   forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2,
                                            y: currentImage.size.height / 2),
                                   forKey: kCIInputCenterKey) }
        
        if let cgimg = context.createCGImage(image,
                                             from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        
        guard let actionTitle = action.title else { return }
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage,
                               forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
@objc func image(_ image: UIImage,
                 didFinishSavingWithError error: Error?,
                 contextInfo: UnsafeRawPointer) {
    
    if let error = error {
        let alertController = UIAlertController(title: "Save Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        alertController.add("Ok",
                            style: .default)
        present(alertController,
                animated: true)
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
}

extension UIAlertController {
    func add(_ title: String,
             style: UIAlertAction.Style = .cancel) {
        let action = UIAlertAction(title: title,
                                         style: style)
        self.addAction(action)
    }
}
