//
//  ViewController.swift
//  Project10
//
//  Created by Dillon McElhinney on 6/27/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController:
    UICollectionViewController,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
    
    var people: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLockView()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(lockView),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }


    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return people.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell",
                                               for: indexPath) as? PersonCollectionViewCell else {
            fatalError("Unable to dequeue a PersonCollectionViewCell. Check for typos")
        }
        let person = people[indexPath.item]

        cell.nameLabel.text = person.name

        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)

        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        presentCellOptionAlert(for: indexPath)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown",
                            image: imageName)
        people.append(person)
        collectionView.reloadData()
        dismiss(animated: true)
}
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            picker.sourceType = .camera
//        }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask).first!
    }
    
    
    private func presentCellOptionAlert(for indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Person",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let renameAction = UIAlertAction(title: "Rename",
                                         style: .default) { [weak self] _ in
            self?.presentRenameAlert(for: indexPath)
        }
        alertController.addAction(renameAction)
        
        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive) { [weak self] _ in
            guard let selfVC = self else { return }
            selfVC.people.remove(at: indexPath.row)
            selfVC.collectionView.deleteItems(at: [indexPath])
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func presentRenameAlert(for indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let alertController = UIAlertController(title: "Rename Person",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addTextField() { textField in
            textField.text = person.name == "Unknown" ? "" : person.name
            textField.placeholder = "Person's Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Ok", style: .default)
        { [weak self, weak alertController] _ in
            guard let newName = alertController?.textFields?.first?.text else { return }
            person.name = newName
            
            self?.collectionView.reloadItems(at: [indexPath])
        }
        
        alertController.addAction(saveAction)
        present(alertController, animated: true)
    }

    lazy var lockedView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.setTitle("Authenticate", for: .normal)
        button.addTarget(self,
                         action: #selector(authenticate),
                         for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }()

    private func setupLockView() {
        view.addSubview(lockedView)
        NSLayoutConstraint.activate([
            lockedView.topAnchor.constraint(equalTo: view.topAnchor),
            lockedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            lockedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lockedView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc private func unlockView() {
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(addNewPerson))

        lockedView.isHidden = true
    }

    @objc private func lockView() {
        navigationItem.rightBarButtonItem = nil
        lockedView.isHidden = false
    }

    @objc func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                     error: &error) {
            let reason = "Use your fingerprint to unlock your saved faces."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        self?.unlockView()
                    } else {
                        let title = "Authentication failed"
                        let message = "You could not be verified; please try again."
                        self?.presentErrorAlert(title: title,
                                                message: message)
                    }
                }
            }
        } else {
            let title = "Biometry unavailable"
            let message = "Your device is not configured for biometric authentication."
            self.presentErrorAlert(title: title,
                                   message: message)
        }
    }
}

extension UIAlertAction {
    static let ok = UIAlertAction(title: "OK",
                                  style: .default)
    static let cancel = UIAlertAction(title: "Cancel",
                                      style: .cancel)
}

extension ViewController {
    func presentErrorAlert(title: String, message: String?) {
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        ac.addAction(.ok)
        self.present(ac, animated: true)
    }
}
