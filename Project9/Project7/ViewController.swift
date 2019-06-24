//
//  ViewController.swift
//  Project7
//
//  Created by Dillon McElhinney on 6/17/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UISearchResultsUpdating {

    var petitions: [Petition] = [] {
        didSet {
            filterPetitions(with: searchController?.searchBar.text)
        }
    }
    var filteredPetitions: [Petition] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }

    // MARK: - UI Table View
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        let petition = filteredPetitions[indexPath.row]

        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(detailVC,
                                                 animated: true)
    }
    
    // MARK: - UI Search Results Updating
    func updateSearchResults(for searchController: UISearchController) {
        filterPetitions(with: searchController.searchBar.text)
    }
    
    private func setupViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(presentCreditAlert))
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self

        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Petitions"

        navigationItem.searchController = searchController

        definesPresentationContext = true
        
        loadPetitions()
    }
    
    private func loadPetitions() {
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100&sortBy=date_reached_public"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=100000&limit=100&sortBy=signature_count&sortOrder=desc"
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString),
                let data = try? Data(contentsOf: url) {
                self?.parse(json: data)
                return
            }
            self?.showError()
        }
    }

    private func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self,
                                                   from: json) {
            petitions = jsonPetitions.results
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        } else {
            showError()
        }
    }
    
    private func showError() {
        presentInformationalAlert(title: .loadingErrorTitle,
                                  message: .loadingErrorMessage)
    }

    @objc private func presentCreditAlert() {
        presentInformationalAlert(title: .creditsTitle,
                                  message: .creditsMessage)
    }
    
    private func presentInformationalAlert(title: String,
                                                 message: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok",
                                       style: .default)
            alertController.addAction(action)
            self?.present(alertController, animated: true)
        }
    }
    
    private func filterPetitions(with string: String?) {
        // Make sure there is a search term, otherwise set the filtered petitions to all the petitions
        guard let searchTerm = string?.lowercased(),
            !searchTerm.isEmpty else {
            self.filteredPetitions = self.petitions
            return
        }
        
        // Get the petitions who's titles match
        let titlesMatch = self.petitions.filter {
            $0.title.lowercased().contains(searchTerm)
        }
        // Get the petitions who's bodies match and aren't in the first group
        let bodiesMatch = self.petitions.filter {
            $0.body.lowercased().contains(searchTerm) &&
                titlesMatch.firstIndex(of: $0) == nil
        }
        
        // Add them together and put them in the filtered array
        self.filteredPetitions = titlesMatch + bodiesMatch
    }
    
}

extension String {
    static let loadingErrorTitle = "Loading error"
    static let loadingErrorMessage = "There was a problem loading the feed. Please check your connection and try again."
    static let creditsTitle = "Credits"
    static let creditsMessage = "Data comes from We The People API of the Whitehouse (api.whitehouse.gov)"
}
