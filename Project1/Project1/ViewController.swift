//
//  ViewController.swift
//  Project1
//
//  Created by Dillon McElhinney on 5/28/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures: [String] = []
    var viewCounts: [String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        loadImages()
        
        print("Finished viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PictureCell", for: indexPath)
        let imageName = pictures[indexPath.row]
        cell.textLabel?.text = imageName
        cell.detailTextLabel?.text = "Views: \(viewCounts[imageName, default: 0])"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if let detailViewController = storyboard?
            .instantiateViewController(withIdentifier: "DetailVC")
            as? DetailViewController {
            let imageName = pictures[indexPath.row]
            viewCounts[imageName, default: 0] += 1
            save()
            
            detailViewController.selectedImage = imageName
            detailViewController.title = "Picture \(indexPath.row + 1) of \(pictures.count)"
            
            navigationController?
                .pushViewController(detailViewController, animated: true)
        }
    }
    
    private func loadImages() {
        DispatchQueue.global().async {
            let fm = FileManager.default
            let path = Bundle.main.resourcePath!
            let items = try! fm.contentsOfDirectory(atPath: path)
            
            for item in items {
                if item.hasPrefix("nssl") {
                    self.pictures.append(item)
                }
            }
            
            self.pictures.sort()
            self.loadViewCounts()
            print("Finished loading pictures")
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
        }
    }
    
    func save() {
        UserDefaults.standard.set(viewCounts, forKey: "viewCounts")
    }

    func loadViewCounts() {
        if let savedViews = UserDefaults.standard.dictionary(forKey: "viewCounts") as? [String: Int] {
            viewCounts = savedViews
        }
    }
}

