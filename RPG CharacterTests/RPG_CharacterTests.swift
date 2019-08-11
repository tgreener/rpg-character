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
    
    var character : RPGCharacter<String>!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let levelSystem = AttributeLevelSystems.linearLevelSystem(slope: 1)
        self.character = RPGCharacter(attributes: [
            ATTR1_NAME : RPGAttribute(progression: 10, baseline: 1, levelSystem: levelSystem),
            ATTR2_NAME : RPGAttribute(progression: 20, baseline: 2, levelSystem: levelSystem),
            ATTR3_NAME : RPGAttribute(progression: 30, baseline: 3, levelSystem: levelSystem),
        ])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCharacter() {
        func testACharacter<Character: CharacterModel>(aCharacter : Character) where Character.AttributeName == String{
            let progression1 = aCharacter[ATTR1_NAME]?.progression
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
    
    private func runLinearDecayTest(slope: AttributeProgressionType, dt : Float) -> RPGCharacter<String> {
        let linearDecayUpdate = self.character.linearDecayUpdate(slope: slope)
        return self.character.update(update: linearDecayUpdate, step: dt)
    }
    
    func testLinearDecay1() {
        var updatedCharacter = runLinearDecayTest(slope: 1, dt: 1)
        
        XCTAssertEqual(updatedCharacter.attributes[ATTR1_NAME]?.progression, 9)
        XCTAssertEqual(updatedCharacter.attributes[ATTR2_NAME]?.progression, 19)
        XCTAssertEqual(updatedCharacter.attributes[ATTR3_NAME]?.progression, 29)
        
        updatedCharacter = updatedCharacter.update(update: updatedCharacter.linearDecayUpdate(slope: 1), step: 1)
        XCTAssertEqual(updatedCharacter.attributes[ATTR1_NAME]?.progression, 8)
        XCTAssertEqual(updatedCharacter.attributes[ATTR2_NAME]?.progression, 18)
        XCTAssertEqual(updatedCharacter.attributes[ATTR3_NAME]?.progression, 28)
    }
    
    func testLinearDecay2() {
        let updatedCharacter = runLinearDecayTest(slope: 2, dt: 0.5)
        
        XCTAssertEqual(updatedCharacter.attributes[ATTR1_NAME]?.progression, 9)
        XCTAssertEqual(updatedCharacter.attributes[ATTR2_NAME]?.progression, 19)
        XCTAssertEqual(updatedCharacter.attributes[ATTR3_NAME]?.progression, 29)
    }
    
    func testLinearDecay3() {
        let updatedCharacter = runLinearDecayTest(slope: 3, dt: 2)
        
        XCTAssertEqual(updatedCharacter.attributes[ATTR1_NAME]?.progression, 4)
        XCTAssertEqual(updatedCharacter.attributes[ATTR2_NAME]?.progression, 14)
        XCTAssertEqual(updatedCharacter.attributes[ATTR3_NAME]?.progression, 24)
    }
    
    func testLinearDecayBaseline() {
        let updatedCharacter = runLinearDecayTest(slope: 10, dt: 3)
        
        XCTAssertEqual(updatedCharacter.attributes[ATTR1_NAME]?.progression, 1)
        XCTAssertEqual(updatedCharacter.attributes[ATTR2_NAME]?.progression, 2)
        XCTAssertEqual(updatedCharacter.attributes[ATTR3_NAME]?.progression, 3)
    }
    
    private func runQuadraticDecayTest(a: AttributeProgressionType, b : AttributeProgressionType, dt : Float) -> RPGCharacter<String> {
        let quadraticDecayUpdate = self.character.quadraticDecayUpdate(a: a, b: b)
        return self.character.update(update: quadraticDecayUpdate, step: dt)
    }
    
    func testQuadraticDecay1() {
        let update = self.character.quadraticDecayUpdate(a: 1, b: 0)
        var updatedCharacter = self.character.update(update: update, step: 2)

        XCTAssertEqual(
            updatedCharacter.attributes[ATTR1_NAME]!.progression,
            1.350889359326483, // (sqrt(10) - 2)^2,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            updatedCharacter.attributes[ATTR2_NAME]!.progression,
            6.111456180001683, // (sqrt(20) - 2)^2
            accuracy: 0.0001
        )
        XCTAssertEqual(
            updatedCharacter.attributes[ATTR3_NAME]!.progression,
            12.09109769979335, // (sqrt(30) - 2)^2
            accuracy: 0.0001
        )

        updatedCharacter = updatedCharacter.update(update: update, step: 1)
        XCTAssertEqual(
            updatedCharacter.attributes[ATTR1_NAME]!.progression,
            1, // (sqrt(1.350889359326483) - 1)^2, hits baseline
            accuracy: 0.0001
        )
        XCTAssertEqual(
            updatedCharacter.attributes[ATTR2_NAME]!.progression,
            2.16718427, // (sqrt(6.111456180001683) - 1)^2
            accuracy: 0.0001
        )
        XCTAssertEqual(
            updatedCharacter.attributes[ATTR3_NAME]!.progression,
            6.1366465497, // (sqrt(12.09109769979335) - 1)^2
            accuracy: 0.0001
        )

        // Force baseline condition
        updatedCharacter = updatedCharacter.update(update: update, step: 100)
        XCTAssertEqual(
            updatedCharacter.attributes[ATTR1_NAME]!.progression,
            1,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            updatedCharacter.attributes[ATTR2_NAME]!.progression,
            2,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            updatedCharacter.attributes[ATTR3_NAME]!.progression,
            3,
            accuracy: 0.0001
        )
    }
}
