//
//  Country.swift
//  Day59Challenge
//
//  Created by Dillon McElhinney on 7/19/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

struct Country: Codable {
    let name: String
    let capital: String
    let population: Int
    let area: Double?
    let currencies: [Currency]
    let languages: [Language]
    let flag: String
    
    static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter
    }()

    private let noDataString = "Unknown"

    var formattedPopulation: String {
        return Country.numberFormatter
            .string(from: population as NSNumber) ?? noDataString
    }

    var formattedArea: String {
        guard let area = area else { return noDataString }
        guard let areaString = Country.numberFormatter
            .string(from: area as NSNumber) else { return noDataString }
        return  areaString + " sq. mi"
    }

    var formattedLanguages: String {
        let allLanguages = languages.compactMap { $0.name }
        return allLanguages.map({ "- \($0)" })
            .joined(separator: "\n")
    }

    var formattedCurrencies: String {
        let allCurrencies = currencies.compactMap { $0.name }
        return allCurrencies.map({ "- \($0)" })
            .joined(separator: "\n")
    }
}

struct Currency: Codable{
    let name: String?
}

struct Language: Codable{
    let name: String?
}
