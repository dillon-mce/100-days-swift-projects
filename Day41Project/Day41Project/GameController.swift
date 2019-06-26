//
//  GameController.swift
//  Day41Project
//
//  Created by Dillon McElhinney on 6/26/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class GameController {
    private(set) var currentWord: String = ""
    private(set) var badGuesses: Int = 0
    private(set) var score: Int = 0

    private var allWords: [String]!
    private var repArray: [String] = []
    private var currentLetters: [Character] = []
    private var lettersGuessed: [Character] = []

    var currentRepresentation: String {
        return repArray.joined(separator: " ")
    }

    var lettersGuessedRepresentation: String {
        return "Letters Guessed: " +
            lettersGuessed
            .map({ String($0) })
            .joined(separator: ", ")
    }
    
    init() {
        loadNewWord()
    }

    func resetGame() {
        loadNewWord()
        score = 0
    }

    func loadNewWord() {
        if allWords == nil {
            guard let url = Bundle.main.url(forResource: "words",
                                            withExtension: "txt"),
                let allWordsString = try? String(contentsOf: url) else {
                    fatalError("Couldn't find the list of words.")
            }
            allWords = allWordsString.components(separatedBy: .newlines)
        }
        
        currentWord = allWords.randomElement()!
        currentLetters = Array(currentWord)
        repArray = Array(repeating: "_", count: currentLetters.count)
        lettersGuessed.removeAll()
        badGuesses = 0
    }
    
    func checkGuess(_ letter: Character) {
        // Make sure the user hasn't already guessed this letter.
        guard !lettersGuessed.contains(letter) else { return }
        // Make sure the letter is a letter
        let scalar = UnicodeScalar(letter.asciiValue ?? 0)
        guard CharacterSet.letters.contains(scalar) else { return }
        
        defer { checkForEndOfGame() }
        
        lettersGuessed.append(letter)
        
        // Check if the letter is in the current word
        guard currentLetters.contains(letter) else {
            badGuesses = badGuesses < 7 ? badGuesses + 1 : 7
            return
        }
        
        // It's a good guess, update the representation
        updateRepresentation(with: letter)
    }
    
    private func updateRepresentation(with letter: Character) {
        for (index, character) in currentLetters.enumerated() {
            if letter == character {
                repArray[index] = String(letter)
                score += 1
            }
        }
    }
    
    private func checkForEndOfGame() {
        if badGuesses >= 7 {
            NotificationCenter.default.post(name: .gameOver, object: self)
            return
        }
        
        if !repArray.contains("_") {
            score += currentWord.count - badGuesses
            NotificationCenter.default.post(name: .levelWon, object: self)
        }
    }
}

extension Notification.Name {
    static let gameOver = Notification.Name("GameOverNotification")
    static let levelWon = Notification.Name("LevelWonNotification")
}
