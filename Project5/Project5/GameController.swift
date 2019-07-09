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
        if let startWordsURL = Bundle.main.url(forResource: "words",
                                               withExtension: "txt"),
            let startWords = try? String(contentsOf: startWordsURL) {
            allWords = startWords.components(separatedBy: "\n")
        }
        
        // Provide a default in case something goes wrong.
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        // Pull saved info out
        startWord = UserDefaults.standard.string(forKey: "startWord") ?? ""
        usedWords = UserDefaults.standard.array(forKey: "usedWords") as? [String] ?? []
    }
    
    // MARK: - Tableview Data Source Helpers
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
        save()
    }
    
    @discardableResult func checkAnswer(_ answer: String) -> AnswerError? {
        let lowerAnswer = answer.lowercased()
        
        guard isPossible(lowerAnswer) else {
            return .impossible(comparedTo: startWord)
        }
        
        guard isOriginal(lowerAnswer) else {
            return .unoriginal
        }
        
        guard isReal(lowerAnswer) else {
            return .unreal
        }
        
        guard isLongEnough(lowerAnswer) else {
            return .tooShort
        }

        guard isNotTheSame(lowerAnswer) else {
            return .sameAsOriginal
        }
        
        usedWords.insert(lowerAnswer, at: 0)
        save()
        
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
    
    private func isLongEnough(_ word: String) -> Bool {
        return word.count > 3
    }

    private func isNotTheSame(_ word: String) -> Bool {
        return word != startWord
    }
    
    
    private func save() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(usedWords, forKey: "usedWords")
        userDefaults.set(startWord, forKey: "startWord")
    }
}

enum AnswerError: Equatable {
    case unoriginal
    case impossible (comparedTo: String)
    case unreal
    case tooShort
    case sameAsOriginal
    
    func title() -> String {
        switch (self) {
        case .impossible:
            return "Word not possible"
        case .unoriginal:
            return "Word used already"
        case .unreal:
            return "Word not recognized"
        case .tooShort:
            return "Word too short"
        case .sameAsOriginal:
            return "Word isn't different"
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
        case .tooShort:
            return "Words need to be at least four letters long!"
        case .sameAsOriginal:
            return "It doesn't count if it is the same word!"
        }
    }
}
