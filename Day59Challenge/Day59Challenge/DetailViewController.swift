//
//  DetailViewController.swift
//  Day59Challenge
//
//  Created by Dillon McElhinney on 7/19/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    var country: Country?

    @IBOutlet var webViewContainer: UIView!
    var flagImageView: WKWebView!

    @IBOutlet var capitalLabel: UILabel!
    @IBOutlet var populationLabel: UILabel!
    @IBOutlet var areaLabel: UILabel!
    @IBOutlet var languagesLabel: UILabel!
    @IBOutlet var currenciesLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        updateViews()
    }

    private func setupViews() {
        flagImageView = WKWebView()
        
        flagImageView.constrainToFill(webViewContainer)
    }

    private func updateViews() {
        guard let country = country else { return }
        
        if let url = URL(string: country.flag) {
            let request = URLRequest(url: url)
            flagImageView.load(request)
        }
        
        title = country.name
        capitalLabel.text = country.capital
        populationLabel.text = country.formattedPopulation
        areaLabel.text = country.formattedArea
        languagesLabel.text = country.formattedLanguages
        currenciesLabel.text = country.formattedCurrencies
    }

}
