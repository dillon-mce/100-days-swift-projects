//
//  ViewController.swift
//  Day23 Challenge
//
//  Created by Dillon McElhinney on 6/5/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var countries: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        countries = items.filter({ $0.hasSuffix("png")})
            .map({ $0.components(separatedBy: ".")[0] })
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell", for: indexPath)
        let country = countries[indexPath.row]
        
        cell.textLabel?.text = country.count < 3 ? country.uppercased() : country.capitalized
        cell.imageView?.image = UIImage(named: country)
        cell.imageView?.addBorder(width: 2, color: .white)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        detailVC.countryName = countries[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }

}

