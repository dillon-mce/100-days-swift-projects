//
//  CountryController.swift
//  Day59Challenge
//
//  Created by Dillon McElhinney on 7/19/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class CountryController {
    
    private var countries: [Country] = [] {
        didSet { updateLetters() }
    }
    private var letters: [String] = []
    private var sortedCountries: [String: [Country]] = [:]
    
    static let shared = CountryController()
    private init() {}
    
    // MARK: TableView Related
    func numberOfSections() -> Int {
        return letters.count
    }

    func title(for section: Int) -> String {
        return letters[section]
    }

    func sectionTitles() -> [String] {
        return letters
    }

    func numberOfRows(in section: Int) -> Int {
        let letter = title(for: section)
        return sortedCountries[letter]?.count ?? 0
    }

    func country(for indexPath: IndexPath) -> Country {
        let letter = title(for: indexPath.section)
        return (sortedCountries[letter]?[indexPath.row])!
    }
    
    // MARK: - Networking
    private let baseURL = URL(string: "https://restcountries.eu/rest/v2/")!
    
    func loadCountries(completion: @escaping () -> Void) {
        let requestURL = baseURL.appendingPathComponent("all")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error GETting all countries:\n\(error)")
                completion()
                return
            }
            
            guard let data = data else {
                NSLog("No data was returned.")
                completion()
                return
            }
            
            do {
                self.countries = try JSONDecoder().decode([Country].self,
                                                          from: data)
            } catch {
                NSLog("Error decoding countries:\n\(error)")
            }
            completion()
            
        }.resume()
    }
    
    private func updateLetters() {
        letters = Set(countries
            .compactMap({ $0.name.first })
            .compactMap({ String($0) }))
            .sorted()
        
        sortedCountries = [:]
        for letter in letters {
            sortedCountries[letter] =
                countries.filter { $0.name.hasPrefix(letter) }
        }
    }
}
