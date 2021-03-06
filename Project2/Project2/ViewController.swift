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
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8,
                                                 y: 0.8)
        }) { _ in
            sender.transform = .identity
            self.answered += 1
            if sender.tag == self.correctAnswer {
                self.score += 1
                self.askQuestion()
            } else {
                self.score -= 1
                self.presentWrongAnswerAlert(country: self.countries[sender.tag].uppercased())
            }
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
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "highScore")
            presentHighScoreAlert(new: score, prev: highScore)
        }
        answered = 0
        score = 0
        askQuestion()
    }
    
    private func presentHighScoreAlert(new: Int, prev: Int) {
        let alertController = UIAlertController(title: "New High Score!",
                                                message: "New high score: \(new)\nPrevious high score:\(prev)",
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Cool!",
                                   style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }

}

extension UIButton {
    func addBorder(width: CGFloat = 1, color: UIColor = .lightGray) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
}
