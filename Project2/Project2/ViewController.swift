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
    var score = 0 {
        didSet {
            updateTitle()
        }
    }
    var correctAnswer = 0
    var answered = 0
    
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        guard answered < 10 else {
            presentEndOfGameAlert()
            return
        }
        countries.shuffle()
        
        for (index, button) in buttons.enumerated() {
            button.setImage(UIImage(named: countries[index]), for: .normal)
        }
        
        correctAnswer = Int.random(in: 0..<buttons.count)
        
        updateTitle()
    }
    
    @IBAction func pickFlag(_ sender: UIButton) {
        answered += 1
        if sender.tag == correctAnswer {
            score += 1
            askQuestion()
        } else {
            score -= 1
            presentWrongAnswerAlert(country: countries[sender.tag].uppercased())
        }
    }
    
    @objc private func presentScoreAlert() {
        let ac = UIAlertController(title: "Your Score",
                                   message: "\(score) points after answering \(answered) questions",
                                   preferredStyle: .alert)
        let action = UIAlertAction(title: "Continue",
                                   style: .default,
                                   handler: { _ in self.dismiss(animated: true) })
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    private func presentWrongAnswerAlert(country: String) {
        let ac = UIAlertController(title: "Wrong!",
                                   message: "That was \(country).",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Continue",
                                   style: .default,
                                   handler: askQuestion)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    private func presentEndOfGameAlert() {
        let ac = UIAlertController(title: "Game over!",
                                   message: "Your score is \(score).",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "New Game",
                                   style: .default,
                                   handler: resetGame)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    private func updateTitle() {
        title = "\(countries[correctAnswer].uppercased())"
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Check Score", style: .plain, target: self, action: #selector(presentScoreAlert))
        
        resetGame()
    }
    
    private func resetGame(action: UIAlertAction! = nil) {
        answered = 0
        score = 0
        askQuestion()
    }

}

extension UIButton {
    func addBorder(width: CGFloat = 1, color: UIColor = .lightGray) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
}
