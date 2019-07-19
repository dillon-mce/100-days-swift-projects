//
//  ViewController.swift
//  Day59Challenge
//
//  Created by Dillon McElhinney on 7/19/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    let countryController = CountryController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryController.loadCountries {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return countryController.numberOfSections()
    }

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return countryController.title(for: section)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return countryController.sectionTitles()
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return countryController.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell",
                                                 for: indexPath)
        let country = countryController.country(for: indexPath)
        
        cell.textLabel?.text = country.name
        let capital = country.capital == "" ? "" : "Capital: \(country.capital)"
        cell.detailTextLabel?.text = capital
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        switch segue.identifier {
        case "ShowCountrySegue":
            let detailVC = segue.destination as! DetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let country = countryController.country(for: indexPath)
            detailVC.country = country
        default:
            break
        }
    }
    
}

