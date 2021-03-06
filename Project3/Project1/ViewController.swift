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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        
        
        pictures.sort()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        let barButton = UIBarButtonItem(barButtonSystemItem: .action,
                                        target: self,
                                        action: #selector(shareApp))
        navigationItem.rightBarButtonItem = barButton
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PictureCell", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if let detailViewController = storyboard?
            .instantiateViewController(withIdentifier: "DetailVC")
            as? DetailViewController {
            detailViewController.selectedImage = pictures[indexPath.row]
            detailViewController.title = "Picture \(indexPath.row + 1) of \(pictures.count)"
            
            navigationController?
                .pushViewController(detailViewController, animated: true)
        }
    }
    
    @objc func shareApp() {
        let string = """
    Check out this cool new app I'm using!
    It is called 'Project1'
    #app_store_link#"
    """
        let activityVC = UIActivityViewController(activityItems: [string], applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}

