//
//  ViewController.swift
//  Project2
//
//  Created by Dillon McElhinney on 5/31/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var countries: [String] = []
    var score = 0
    
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        askQuestion()
    }

    func askQuestion() {
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
    }
    
    private func setup() {
        countries = ["estonia",
                     "france",
                     "germany",
                     "ireland",
                     "italy",
                     "monaco",
                     "nigeria",
                     "poland",
                     "russia",
                     "spain",
                     "uk",
                     "us"]
        
        button1.addBorder()
        button2.addBorder()
        button3.addBorder()
    }

}

extension UIButton {
    func addBorder(width: CGFloat = 1, color: UIColor = .lightGray) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
}
