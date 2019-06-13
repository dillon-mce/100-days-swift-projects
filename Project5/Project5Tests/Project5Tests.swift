//
//  Project5Tests.swift
//  Project5Tests
//
//  Created by Dillon McElhinney on 6/11/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import XCTest
@testable import Project5

class Project5Tests: XCTestCase {
    
    var gameController: GameController!
    let startWord = "gumdrops"
    
    override func setUp() {
        gameController = GameController()
        gameController.startWord = startWord
    }
    
    override func tearDown() {
        gameController = nil
    }
    
    func testValidWord() {
        let prevCount = gameController.numberOfRows()

        let error = gameController.checkAnswer("gumdrop")
        
        XCTAssertNil(error, "Returned an error for a valid word.")
        XCTAssertEqual(gameController.numberOfRows(), prevCount + 1)
        let indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(gameController.word(for: indexPath), "gumdrop")
    }
    
    func testSameWordCapitalAndLower() {
        let prevCount = gameController.numberOfRows()
        
        gameController.checkAnswer("Gumdrop")
        let error = gameController.checkAnswer("gumdrop")
        
        XCTAssertEqual(error, AnswerError.unoriginal)
        XCTAssertEqual(gameController.numberOfRows(), prevCount + 1)
        
    }
    
    func testWeirdCases() {
        let prevCount = gameController.numberOfRows()
        
        gameController.checkAnswer("GumDRop")
        gameController.checkAnswer("gUmdrOp")
        let error = gameController.checkAnswer("gumdrop")
        
        XCTAssertEqual(error, AnswerError.unoriginal)
        XCTAssertEqual(gameController.numberOfRows(), prevCount + 1)
    }
    
    func testRepeatedWord() {
        let prevCount = gameController.numberOfRows()
        
        gameController.checkAnswer("drops")
        let error = gameController.checkAnswer("drops")
        
        XCTAssertEqual(error, AnswerError.unoriginal)
        XCTAssertEqual(gameController.numberOfRows(), prevCount + 1)
        
    }

    func testUnrealWord() {
        let prevCount = gameController.numberOfRows()
        
        let error = gameController.checkAnswer("dropus")
        
        XCTAssertEqual(error, AnswerError.unreal)
        XCTAssertEqual(gameController.numberOfRows(), prevCount)
    }

    func testImpossibleWord() {
        let prevCount = gameController.numberOfRows()
        
        let error = gameController.checkAnswer("raindrop")
        
        XCTAssertEqual(error, AnswerError.impossible(comparedTo: startWord))
        XCTAssertEqual(gameController.numberOfRows(), prevCount)
    }
    
    func testTooShortWord() {
        let prevCount = gameController.numberOfRows()
        
        let error = gameController.checkAnswer("gum")
        
        XCTAssertEqual(error, AnswerError.tooShort)
        XCTAssertEqual(gameController.numberOfRows(), prevCount)
    }

    func testSameWord() {
        let prevCount = gameController.numberOfRows()
        
        let error = gameController.checkAnswer("gumdrops")
        
        XCTAssertEqual(error, AnswerError.sameAsOriginal)
        XCTAssertEqual(gameController.numberOfRows(), prevCount)
    }

}
