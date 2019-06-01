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
    var correctAnswer = 0
    
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        
        for (index, button) in buttons.enumerated() {
            button.setImage(UIImage(named: countries[index]), for: .normal)
        }
        
        correctAnswer = Int.random(in: 0..<buttons.count)
        
        title = countries[correctAnswer].uppercased()
    }
    
    @IBAction func pickFlag(_ sender: UIButton) {
        var title: String

        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong"
            score -= 1
        }
        
        let ac = UIAlertController(title: title,
                                   message: "Your score is \(score).",
                                   preferredStyle: .alert)
        let action = UIAlertAction(title: "Continue",
                                   style: .default,
                                   handler: askQuestion)
        ac.addAction(action)
        present(ac, animated: true)
        
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
        
        for (index, button) in buttons.enumerated() {
            button.addBorder()
            button.tag = index
        }
    }

}

extension UIButton {
    func addBorder(width: CGFloat = 1, color: UIColor = .lightGray) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
}
