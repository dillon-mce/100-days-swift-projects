//
//  ViewController.swift
//  Day90Challenge
//
//  Created by Dillon McElhinney on 10/18/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8

        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground

        return imageView
    }()

    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually

        return stackView
    }()

    private lazy var addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New Photo",
                        for: .normal)
        button.addTarget(self,
                         action: #selector(pickPhoto),
                         for: .touchUpInside)
        return button
    }()

    private lazy var addTopTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Top Text",
                        for: .normal)
        button.addTarget(self,
                         action: #selector(setText),
                         for: .touchUpInside)
        return button
    }()

    private lazy var addBottomTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Bottom Text",
                        for: .normal)
        button.addTarget(self,
                         action: #selector(setText),
                         for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutViews()
    }

    @objc func setText(_ sender: UIButton) {
        guard imageView.image != nil else { return }
        let title = "What text would you like to add?"
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)
        var memeTextField: UITextField!
        alertController.addTextField { textfield in
            textfield.placeholder = "Your text here"
            textfield.autocapitalizationType = .words
            memeTextField = textfield
        }
        let location: TextLocation = sender == addTopTextButton ? .top : .bottom
        let add = UIAlertAction(title: "Add", style: .default) { _ in
            guard let text = memeTextField.text else { return }
            self.addText(text, for: location)
        }
        alertController.addAction(add)
        alertController.addAction(.cancel)

        present(alertController, animated: true)
    }

    @objc func pickPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

@objc func sharePhoto() {
    guard let image = imageView.image,
        let imageData = image.pngData() else { return }
    let activityViewController =
        UIActivityViewController(activityItems: [imageData],
                                 applicationActivities: nil)
    present(activityViewController, animated: true)
}

    private func layoutViews() {
        title = "Meme Maker"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(sharePhoto))

        mainStackView.constrainToSuperView(view,
                                           safeArea: true,
                                           centerX: 0,
                                           centerY: 0)
        mainStackView.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor,
                                             constant: -40).isActive = true
        mainStackView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor,
                                              constant: -40).isActive = true

        imageView.constrainSelf(aspectWidth: 1)
        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(buttonStackView)

        buttonStackView.addArrangedSubview(addTopTextButton)
        buttonStackView.addArrangedSubview(addImageButton)
        buttonStackView.addArrangedSubview(addBottomTextButton)
    }

    private func aspectFillRectFor(size: CGSize, in square: CGSize) -> CGRect {
        if size.width < size.height {
            // calculate for tall image
            let width = square.width
            let height = square.width * size.height / size.width
            let x: CGFloat = 0
            let y = -(height - square.width) / 2
            return CGRect(x: x, y: y, width: width, height: height)
        } else {
            // calculate for wide image
            let height = square.height
            let width = square.height * size.width / size.height
            let x = -(width - square.height) / 2
            let y: CGFloat = 0
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }

    private func addText(_ text: String, for location: TextLocation) {
        guard let image = imageView.image else { return }

        let size = imageView.frame.size * 2
        let renderer = UIGraphicsImageRenderer(size: size)

        let newImage = renderer.image { context in

            let rect = aspectFillRectFor(size: image.size, in: size)
            image.draw(in: rect)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let shadow = NSShadow()
            shadow.shadowColor = UIColor(white: 0, alpha: 0.6)
            shadow.shadowBlurRadius = 4
            shadow.shadowOffset = CGSize(width: 2, height: 2)

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: size.width / 10),
                .shadow: shadow,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            let attributedString = NSAttributedString(string: text,
                                                      attributes: attrs)
            let stringRect: CGRect
            switch location {
            case .top:
                stringRect = CGRect(x: 12,
                                    y: 0,
                                    width: size.width - 24,
                                    height: size.height / 2)
                attributedString.draw(with: stringRect,
                                      options: .usesLineFragmentOrigin,
                                      context: nil)
            case .bottom:
                stringRect = CGRect(x: 12,
                                    y: size.height - 18,
                                    width: size.width - 24,
                                    height: size.height / 2)
                attributedString.draw(with: stringRect,
                                      options: [.truncatesLastVisibleLine],
                                      context: nil)
            }

        }

        imageView.image = newImage
        switch location {
        case .top: addTopTextButton.isEnabled = false
        case .bottom: addBottomTextButton.isEnabled = false
        }
    }

    enum TextLocation {
        case top, bottom
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

        imageView.image = image
        addTopTextButton.isEnabled = true
        addBottomTextButton.isEnabled = true
        dismiss(animated: true)
    }
}

extension UIAlertAction {
    static let cancel = UIAlertAction(title: "Cancel", style: .cancel)
}

extension CGSize {
    func multiply(by factor: CGFloat) -> CGSize {
        return CGSize(width: self.width * factor, height: self.height * factor)
    }
}

infix operator *: MultiplicationPrecedence
func * (left: CGSize, right: CGFloat) -> CGSize { return left.multiply(by: right) }
