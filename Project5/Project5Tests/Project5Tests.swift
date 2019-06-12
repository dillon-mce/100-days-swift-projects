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

        let alert = gameController.checkAnswer("gumdrop")
        
        XCTAssertNil(alert, "Returned an alert for a valid word.")
        XCTAssertEqual(gameController.numberOfRows(), prevCount + 1)
        let indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(gameController.word(for: indexPath), "gumdrop")
    }
    
    func testRepeatedWord() {
        let prevCount = gameController.numberOfRows()
        
        gameController.checkAnswer("drops")
        let alert = gameController.checkAnswer("drops")
        
        XCTAssertNotNil(alert)
        XCTAssertEqual(alert?.title, AnswerError.unoriginal.title())
        XCTAssertEqual(gameController.numberOfRows(), prevCount + 1)
        
    }

    func testUnrealWord() {
        let prevCount = gameController.numberOfRows()
        
        let alert = gameController.checkAnswer("dropus")
        
        XCTAssertNotNil(alert)
        XCTAssertEqual(alert?.title, AnswerError.unreal.title())
        XCTAssertEqual(gameController.numberOfRows(), prevCount)
    }

    func testImpossibleWord() {
        let prevCount = gameController.numberOfRows()
        
        let alert = gameController.checkAnswer("raindrop")
        
        XCTAssertNotNil(alert)
        XCTAssertEqual(alert?.title, AnswerError.impossible(comparedTo: startWord).title())
        XCTAssertEqual(gameController.numberOfRows(), prevCount)
    }

}
