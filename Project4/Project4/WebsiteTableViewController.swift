//
//  WebsiteTableViewController.swift
//  Project4
//
//  Created by Dillon McElhinney on 6/8/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class WebsiteTableViewController: UITableViewController {

    let websiteController = WebsiteController()

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int)
        -> Int {
            
        return websiteController.numberOfRows()
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "WebsiteCell",
                                 for: indexPath)
        let website = websiteController.website(for: indexPath)
        
        cell.textLabel?.text = website

        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let websiteVC = storyboard?
            .instantiateViewController(withIdentifier: "WebsiteVC")
            as! ViewController
        let website = websiteController.website(for: indexPath)
        
        websiteVC.websiteController = websiteController
        websiteVC.selectedWebsite = website
        
        navigationController?
            .pushViewController(websiteVC, animated: true)
    }

}
