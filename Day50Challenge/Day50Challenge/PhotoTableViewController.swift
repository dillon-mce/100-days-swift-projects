//
//  PhotoTableViewController.swift
//  Day50Challenge
//
//  Created by Dillon McElhinney on 7/9/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class PhotoTableViewController: UITableViewController,
                                UINavigationControllerDelegate,
                                UIImagePickerControllerDelegate {
    private let cellIdentifier = "PhotoCell"

    var photos: [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photos"
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(addPhoto))

        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: cellIdentifier)
        
        load()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath)
        let photo = photos[indexPath.row]
        let filePath = URL.documentPath(for: photo.fileName).path

        cell.textLabel?.text = photo.caption
        cell.imageView?.image = UIImage(contentsOfFile: filePath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        photos.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        save()
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        let detailVC = DetailViewController()
        detailVC.photo = photo
        detailVC.saveHandler = { [weak self] in
            self?.tableView.reloadData()
            self?.save()
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Image Picker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let fileName = UUID().uuidString
        let filePath = URL.documentPath(for: fileName)
        
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else { return }
        
        do {
            try jpegData.write(to: filePath)
        } catch {
            print("Error saving image:\n\(error)")
            return
        }
        
        let photo = Photo(fileName: fileName)
        
        photos.append(photo)
        tableView.insertRows(at: [IndexPath(row: photos.count-1, section: 0)], with: .automatic)
        save()
        dismiss(animated: true)
        
    }
    
    @objc func addPhoto() {
        let alertController = UIAlertController(title: "Add a photo",
                                                message: "Where would you like to add a photo from?",
                                                preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.presentImagePicker(with: .camera)
        }
        alertController.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.presentImagePicker()
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func presentImagePicker(with source: UIImagePickerController.SourceType = .photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            imagePicker.sourceType = source
        }
        
        present(imagePicker, animated: true)
    }
    
    private func save() {
        do {
            let jsonData = try JSONEncoder().encode(photos)
            UserDefaults.standard.set(jsonData, forKey: "photos")
        } catch {
            print("Error saving photos:\n\(error)")
        }
    }

    private func load() {
        guard let savedData = UserDefaults.standard.object(forKey: "photos") as? Data else { return }
        do {
            photos = try JSONDecoder().decode([Photo].self, from: savedData)
        } catch {
            print("Error loading photos:\n\(error)")
        }
    }

}

extension URL {
    static func documentPath(for string: String? = nil) -> URL {
        var documents = FileManager.default.urls(for: .documentDirectory,
                                                 in: .userDomainMask).first!
        if let string = string {
            documents.appendPathComponent(string)
        }
        return documents
    }
}
