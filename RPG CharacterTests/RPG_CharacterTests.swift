//
//  RPG_CharacterTests.swift
//  RPG CharacterTests
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import XCTest
@testable import RPG_Character

let ATTR1_NAME = "attr1"
let ATTR2_NAME = "attr2"
let ATTR3_NAME = "attr3"

class RPG_CharacterTests: XCTestCase {
    
    var character : CharacterModel!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let levelSystem = CharacterAttributeLevelSystems.linearLevelSystem(step: 1)
        self.character = RPGCharacter(attributes: [
            ATTR1_NAME : RPGCharacterAttribute(progression: 10, baseline: 1, levelSystem: levelSystem),
            ATTR2_NAME : RPGCharacterAttribute(progression: 20, baseline: 2, levelSystem: levelSystem),
            ATTR3_NAME : RPGCharacterAttribute(progression: 30, baseline: 3, levelSystem: levelSystem)
        ])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCharacter() {
        func testACharacter(aCharacter : CharacterModel) {
            let progression1 = aCharacter.attributes[ATTR1_NAME]?.progression
            XCTAssert(progression1 == 10, "Unexpected value for \(ATTR1_NAME) progression : \(String(describing: progression1))")
            
            let progression2 = aCharacter[ATTR2_NAME]?.progression
            XCTAssert(progression2 == 20, "Unexpected value for \(ATTR2_NAME) progression : \(String(describing: progression2))")
            
            let progression3 = aCharacter[ATTR3_NAME]?.progression
            XCTAssert(progression3 == 30, "Unexpected value for \(ATTR3_NAME) progression : \(String(describing: progression3))")
            
            let baseline1 = aCharacter[ATTR1_NAME]?.baseline
            XCTAssert(baseline1 == 1, "Unexpected value for \(ATTR1_NAME) baseline : \(String(describing: baseline1))")
            
            let baseline2 = aCharacter[ATTR2_NAME]?.baseline
            XCTAssert(baseline2 == 2, "Unexpected value for \(ATTR2_NAME) baseline : \(String(describing: baseline2))")
            
            let baseline3 = aCharacter[ATTR3_NAME]?.baseline
            XCTAssert(baseline3 == 3, "Unexpected value for \(ATTR3_NAME) baseline : \(String(describing: baseline3))")
        }
        
        testACharacter(aCharacter: self.character)
        testACharacter(aCharacter: RPGCharacter(character: self.character))
    }
    
    func testZeroedLevelSystem() {
        let levelSystem = CharacterAttributeLevelSystems.zeroed()
        (0...100).forEach { XCTAssert(levelSystem.levelFunction(Float($0)) == 0) }
        (1...100).forEach { XCTAssert(levelSystem.inverseLevelFunction($0) == 0) }
    }
    
    func testLinearLevelSystem() {
        let levelSystem = CharacterAttributeLevelSystems.linearLevelSystem(step: 1)
        (0...100).forEach { XCTAssertEqual(levelSystem.levelFunction(Float($0)), $0 + 1) }
        (1...100).forEach { XCTAssertEqual(levelSystem.inverseLevelFunction($0), Float($0 - 1)) }
        
        let levelSystem2 = CharacterAttributeLevelSystems.linearLevelSystem(step: 10)
        XCTAssertEqual(levelSystem2.levelFunction(Float(1)), 1)
        XCTAssertEqual(levelSystem2.levelFunction(Float(10)), 2)
        XCTAssertEqual(levelSystem2.levelFunction(Float(100)), 11)
        XCTAssertEqual(levelSystem2.inverseLevelFunction(1), 0)
        XCTAssertEqual(levelSystem2.inverseLevelFunction(2), 10)
        XCTAssertEqual(levelSystem2.inverseLevelFunction(3), 20)
    }
    
    func testQuadraticLevelSystem() {
        let levelSystem = CharacterAttributeLevelSystems.quadraticLevelSystem(a: 1)
        XCTAssertEqual(levelSystem.levelFunction(Float(0)), 1)
        XCTAssertEqual(levelSystem.levelFunction(Float(1)), 2)
        XCTAssertEqual(levelSystem.levelFunction(Float(3)), 2)
        XCTAssertEqual(levelSystem.levelFunction(Float(4)), 3)
        XCTAssertEqual(levelSystem.levelFunction(Float(5)), 3)
        XCTAssertEqual(levelSystem.levelFunction(Float(9)), 4)
        XCTAssertEqual(levelSystem.levelFunction(Float(16)), 5)
        XCTAssertEqual(levelSystem.levelFunction(Float(25)), 6)
        
        XCTAssertEqual(levelSystem.inverseLevelFunction(1), 0)
        XCTAssertEqual(levelSystem.inverseLevelFunction(2), 1)
        XCTAssertEqual(levelSystem.inverseLevelFunction(3), 4)
        XCTAssertEqual(levelSystem.inverseLevelFunction(4), 9)
        XCTAssertEqual(levelSystem.inverseLevelFunction(5), 16)
        XCTAssertEqual(levelSystem.inverseLevelFunction(6), 25)
        
        let levelSystem2 = CharacterAttributeLevelSystems.quadraticLevelSystem(a: 2, b: 4, c: 5)
        XCTAssertEqual(levelSystem2.inverseLevelFunction(1), 5)
        XCTAssertEqual(levelSystem2.inverseLevelFunction(2), 11)
        XCTAssertEqual(levelSystem2.inverseLevelFunction(3), 21)
        
        XCTAssertEqual(levelSystem2.levelFunction(5), 1)
        XCTAssertEqual(levelSystem2.levelFunction(6), 1)
        XCTAssertEqual(levelSystem2.levelFunction(10.999), 1)
        XCTAssertEqual(levelSystem2.levelFunction(11), 2)
        XCTAssertEqual(levelSystem2.levelFunction(11.001), 2)
        XCTAssertEqual(levelSystem2.levelFunction(21), 3)
    }
    
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
