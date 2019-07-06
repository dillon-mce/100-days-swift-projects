//
//  ViewController.swift
//  Project10
//
//  Created by Dillon McElhinney on 6/27/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController:
    UICollectionViewController,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
    
    var people: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(addNewPerson))
        
        loadPeople()
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
        save()
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
            selfVC.save()
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
            textField.autocapitalizationType = .words
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Ok", style: .default)
        { [weak self, weak alertController] _ in
            guard let newName = alertController?.textFields?.first?.text else { return }
            person.name = newName

            self?.collectionView.reloadItems(at: [indexPath])
            self?.save()
        }
        
        alertController.addAction(saveAction)
        present(alertController, animated: true)
    }
    
    private func save() {
        if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: people,
                                                            requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(saveData, forKey: "people")
        }
    }
    
    private func loadPeople() {
        let defaults = UserDefaults.standard
        guard let savedPeople = defaults.object(forKey: "people") as? Data else { return }
        guard let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] else { return }
        
        people = decodedPeople
    }
}

