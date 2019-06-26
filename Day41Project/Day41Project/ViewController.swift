//
//  ViewController.swift
//  Day41Project
//
//  Created by Dillon McElhinney on 6/26/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let gameController = GameController()

    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var badGuessLabel: UILabel!
    @IBOutlet var hangmanImageView: UIImageView!
    @IBOutlet var lettersGuessedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }

    @IBAction func makeGuess(_ sender: Any) {
        presentGuessAlert()
    }
    
    private func setupViews() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(endOfGame),
                                               name: .gameOver,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(levelWon),
                                               name: .levelWon,
                                               object: nil)
        
        gameController.loadNewWord()
        updateViews()
    }
    
    private func updateViews() {
        title = gameController.currentRepresentation
        
        scoreLabel.text = "Score: \(gameController.score)"
        badGuessLabel.text = "Bad Guesses: \(gameController.badGuesses)"
        hangmanImageView.image = UIImage(named: "hangman-\(gameController.badGuesses)")
        lettersGuessedLabel.text = gameController.lettersGuessedRepresentation
        
    }
    
    private func presentGuessAlert() {
        let alertController = UIAlertController(title: "Make a guess",
                                                message: nil,
                                                preferredStyle: .alert)
        var guessTextField: UITextField!
        alertController.addTextField { (textField) in
            textField.placeholder = "Your guess"
            guessTextField = textField
        }
        
        let submitAction = UIAlertAction(title: "Submit",
                                         style: .default) { _ in
            guard let guess = guessTextField.text?.lowercased() else { return }
            self.submit(guess)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func submit(_ guess: String) {
        for letter in guess {
            gameController.checkGuess(letter)
            updateViews()
        }
    }
    
    private func presentInformationalAlert(title: String,
                                           message: String,
                                           showCancel: Bool = false,
                                           buttonTitle: String = "Ok",
                                           buttonHandler: @escaping (UIAlertAction) -> Void = { _ in }) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonTitle,
                                   style: .default,
                                   handler: buttonHandler)
        alertController.addAction(action)
        
        if showCancel {
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .default)
            alertController.addAction(cancelAction)
        }
        
        present(alertController, animated: true)
    }
    
    
    @objc private func endOfGame() {
        let word = gameController.currentWord
        let score = gameController.score
        let message = """
        "You didn't beat the noose this time.
        We were looking for '\(word)'.
        Your score was: \(score)"
        """
        presentInformationalAlert(title: "Game Over!",
                                  message: message,
                                  buttonTitle: "Try Again") { _ in
            self.gameController.resetGame()
            self.updateViews()
        }
    }

    @objc private func levelWon() {
        presentInformationalAlert(title: "You got it!",
                                  message: "You live to see another day",
                                  buttonTitle: "Next Level") { _ in
            self.gameController.loadNewWord()
            self.updateViews()
        }
    }
}

