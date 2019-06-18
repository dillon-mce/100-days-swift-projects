//
//  ViewController.swift
//  Project7
//
//  Created by Dillon McElhinney on 6/17/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var petitions: [Petition] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPetitions()
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        let petition = petitions[indexPath.row]

        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(detailVC,
                                                 animated: true)
    }
    
    private func loadPetitions() {
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=100000&limit=100"
        }
        
        if let url = URL(string: urlString),
            let data = try? Data(contentsOf: url) {
            parse(json: data)
        } else {
            showError()
        }
    }

    private func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self,
                                                   from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        } else {
            showError()
        }
    }
    
    private func showError() {
        let alertController = UIAlertController(title: "Loading error",
                                                message: "There was a problem loading the feed. Please check your connection and try again.",
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok",
                                   style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
}

