//
//  GameController.swift
//  Project5
//
//  Created by Dillon McElhinney on 6/11/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class GameController {
    
    private var allWords: [String] = []
    private var usedWords: [String] = []
    var startWord: String = ""
    
    init() {
        // Pull the list of words out of the file
        if let startWordsURL = Bundle.main.url(forResource: "start",
                                               withExtension: "txt"),
            let startWords = try? String(contentsOf: startWordsURL) {
            allWords = startWords.components(separatedBy: "\n")
        }
        
        // Provide a default in case something goes wrong.
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
    }
    
    // MARK: - Tableview Data Source
    func numberOfRows(in section: Int = 0) -> Int {
        return usedWords.count
    }
    
    func word(for indexPath: IndexPath) -> String {
        return usedWords[indexPath.row]
    }
    
    // MARK: - Public API
    func startGame() {
        startWord = allWords.randomElement() ?? "silkworm"
        usedWords.removeAll()
    }
    
    @discardableResult func checkAnswer(_ answer: String) -> UIAlertController? {
        let lowerAnswer = answer.lowercased()
        
        guard isPossible(lowerAnswer) else {
            return buildErrorAlert(for: .impossible(comparedTo: startWord))
        }
        
        guard isOriginal(lowerAnswer) else {
            return buildErrorAlert(for: .unoriginal)
        }
        
        guard isReal(lowerAnswer) else {
            return buildErrorAlert(for: .unreal)
        }
        
        usedWords.insert(answer, at: 0)
        
        return nil
    }
    
private func isPossible(_ word: String) -> Bool {
    var tempWord = startWord.lowercased()
    
    for letter in word {
        if let position = tempWord.firstIndex(of: letter) {
            tempWord.remove(at: position)
        } else {
            return false
        }
    }
    return true
}

private func isOriginal(_ word: String) -> Bool {
    return !usedWords.contains(word)
}

private func isReal(_ word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0,
                        length: word.utf16.count)
    let misspelledRange =
        checker.rangeOfMisspelledWord(in: word,
                                      range: range,
                                      startingAt: 0,
                                      wrap: false,
                                      language: "en")
    return misspelledRange.location == NSNotFound
}
    
    private func buildErrorAlert(for error: AnswerError) -> UIAlertController {
        let alertController = UIAlertController(title: error.title(),
                                                message: error.message(),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default)
        alertController.addAction(okAction)
        return alertController
    }
}

enum AnswerError {
    case unoriginal
    case impossible (comparedTo: String)
    case unreal
    
    func title() -> String {
        switch (self) {
        case .impossible:
            return "Word not possible"
        case .unoriginal:
            return "Word used already"
        case .unreal:
            return "Word not recognized"
        }
    }
    
    func message() -> String {
        switch (self) {
        case .impossible(let word):
            return "You can't spell that word from '\(word)'"
        case .unoriginal:
            return "Be more original!"
        case .unreal:
            return "You can't just make them up, you know!"
        }
    }
}
