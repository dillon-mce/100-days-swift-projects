//
//  ViewController.swift
//  Project8
//
//  Created by Dillon McElhinney on 6/20/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons: [UIButton] = []
    var activatedButtons: [UIButton] = []
    var solutions: [String] = []
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    private let fadeDuration = 0.3
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "Clues".uppercased()
        cluesLabel.numberOfLines = 0
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)

        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.text = "Answers".uppercased()
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("Submit".uppercased(), for: .normal)
        submit.addTarget(self,
                         action: #selector(submitAnswer),
                         for: .touchUpInside)
        view.addSubview(submit)

        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("Clear".uppercased(), for: .normal)
        clear.addTarget(self,
                        action: #selector(clearAnswer),
                        for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonsView = UIView()
        buttonsView.layer.borderColor = UIColor.lightGray.cgColor
        buttonsView.layer.borderWidth = 2
        buttonsView.layer.cornerRadius = 12
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
                scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
                cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
                cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
                cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
                answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
                answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
                answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
                answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
                currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
                submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
                submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
                submit.heightAnchor.constraint(equalToConstant: 44),
                clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
                clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
                clear.heightAnchor.constraint(equalToConstant: 44),
                buttonsView.widthAnchor.constraint(equalToConstant: 750),
                buttonsView.heightAnchor.constraint(equalToConstant: 320),
                buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
                buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        let width = 150
        let height = 80

        for row in 0...3 {
            for col in 0...4 {
                let letterButton = UIButton(type: .custom)
                letterButton.setTitleColor(.systemBlue, for: .normal)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.addTarget(self,
                                       action: #selector(letterTapped),
                                       for: .touchUpInside)
                let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLevel()
    }

    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        UIView.animate(withDuration: fadeDuration) {
            sender.alpha = 0
        }
    }

    @objc func submitAnswer(_ sender: UIButton) {
        guard let answerText = currentAnswer.text else { return }

        guard let solutionPosition = solutions.firstIndex(of: answerText) else {
            score -= 1
            presentAlert(title: "Wrong answer!",
                         message: "Sorry, that isn't a valid word.",
                         buttonTitle: "Ok")
            return
        }

        activatedButtons.removeAll()
        var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
        splitAnswers?[solutionPosition] = answerText
        let isLevelOver = splitAnswers == solutions
        answersLabel.text = splitAnswers?.joined(separator: "\n")

        currentAnswer.text = ""
        score += 1

        if isLevelOver {
            presentAlert(title: "Well done!",
                         message: "Are you ready for the next level?",
                         buttonTitle: "Let's go!",
                         handler: levelUp)
        }
    }

    @objc func clearAnswer(_ sender: UIButton) {
        currentAnswer.text = ""
        
        UIView.animate(withDuration: fadeDuration*2) {
            for button in self.activatedButtons {
                button.alpha = 1
            }
        }

        activatedButtons.removeAll()
    }
    
    private func loadLevel() {
        DispatchQueue.global().async {
            var clueString = ""
            var solutionString = ""
            var letterBits: [String] = []
            
            guard let levelFileURL = Bundle.main.url(forResource: "level\(self.level)",
                withExtension: "txt") else { return }
            guard let levelContents = try? String(contentsOf: levelFileURL) else { return }
            
            var lines = levelContents.components(separatedBy: "\n")
            lines.shuffle()
            
            for (index, line) in lines.enumerated() {
                let parts = line.components(separatedBy: ": ")
                let answer = parts[0]
                let clue = parts[1]
                
                clueString += "\(index + 1). \(clue)\n"
                
                let solutionWord = answer.replacingOccurrences(of: "|",
                                                               with: "")
                solutionString += "\(solutionWord.count) letters\n"
                self.solutions.append(solutionWord)
                
                let bits = answer.components(separatedBy: "|")
                letterBits += bits
            }
            DispatchQueue.main.async {
                self.cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
                self.answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                letterBits.shuffle()
                
                if letterBits.count == self.letterButtons.count {
                    for i in 0..<self.letterButtons.count {
                        self.letterButtons[i].setTitle(letterBits[i],
                                                  for: .normal)
                    }
                }
            }
        }

    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for button in letterButtons {
            button.alpha = 1
        }
    }
    
    func presentAlert(title: String,
                      message: String,
                      buttonTitle: String,
                      handler: @escaping (UIAlertAction) -> Void = { _ in }) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle,
                                   style: .default,
                                   handler: handler)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
}

extension UIColor {
    static let systemBlue = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
}
