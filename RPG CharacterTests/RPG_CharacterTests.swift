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
        let levelSystem = AttributeLevelSystems.linearLevelSystem(step: 1)
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
        func testACharacter(aCharacter : CharacterModel) {
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
    
    func testZeroedLevelSystem() {
        let levelSystem = AttributeLevelSystems.zeroed()
        (0...100).forEach { XCTAssert(levelSystem.levelFunction(Float($0)) == 0) }
        (1...100).forEach { XCTAssert(levelSystem.inverseLevelFunction($0) == 0) }
    }
    
    func testLinearLevelSystem() {
        let levelSystem = AttributeLevelSystems.linearLevelSystem(step: 1)
        (0...100).forEach { XCTAssertEqual(levelSystem.levelFunction(Float($0)), $0 + 1) }
        (1...100).forEach { XCTAssertEqual(levelSystem.inverseLevelFunction($0), Float($0 - 1)) }
        
        let levelSystem2 = AttributeLevelSystems.linearLevelSystem(step: 10)
        XCTAssertEqual(levelSystem2.levelFunction(Float(1)), 1)
        XCTAssertEqual(levelSystem2.levelFunction(Float(10)), 2)
        XCTAssertEqual(levelSystem2.levelFunction(Float(100)), 11)
        XCTAssertEqual(levelSystem2.inverseLevelFunction(1), 0)
        XCTAssertEqual(levelSystem2.inverseLevelFunction(2), 10)
        XCTAssertEqual(levelSystem2.inverseLevelFunction(3), 20)
    }
    
    func testQuadraticLevelSystem() {
        let levelSystem = AttributeLevelSystems.quadraticLevelSystem(a: 1)
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
        
        let levelSystem2 = AttributeLevelSystems.quadraticLevelSystem(a: 2, b: 4, c: 5)
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
    
    private func runLinearDecayTest(slope: AttributeProgressionType, dt : Float) -> CharacterModel{
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
    
    private func runQuadraticDecayTest(a: AttributeProgressionType, b : AttributeProgressionType, dt : Float) -> CharacterModel{
        let quadraticDecayUpdate = self.character.quadraticDecayUpdate(a: a, b: b)
        return self.character.update(update: quadraticDecayUpdate, step: dt)
    }
    
    private func basicallyEqual(a : Float, b : Float) {
        let places : Float = Float(10^5)
        let aRounded = (Float(a) * places).rounded(.towardZero) / places
        let bRounded = (Float(b) * places).rounded(.towardZero) / places
        XCTAssertEqual(aRounded, bRounded)
    }
    
    func testQuadraticDecay1() {
        let update = self.character.quadraticDecayUpdate(a: 1, b: 0)
        var updatedCharacter = self.character.update(update: update, step: 2)

        basicallyEqual(
            a: updatedCharacter.attributes[ATTR1_NAME]!.progression,
            b: 1.350889359326483 // (sqrt(10) - 2)^2
        )
        basicallyEqual(
            a: updatedCharacter.attributes[ATTR2_NAME]!.progression,
            b: 6.111456180001683 // (sqrt(20) - 2)^2
        )
        basicallyEqual(
            a: updatedCharacter.attributes[ATTR3_NAME]!.progression,
            b: 12.09109769979335 // (sqrt(30) - 2)^2
        )
        
        updatedCharacter = updatedCharacter.update(update: update, step: 1)
        basicallyEqual(
            a: updatedCharacter.attributes[ATTR1_NAME]!.progression,
            b: 1 // (sqrt(1.350889359326483) - 1)^2, hits baseline
        )
        basicallyEqual(
            a: updatedCharacter.attributes[ATTR2_NAME]!.progression,
            b: 2.16718427 // (sqrt(6.111456180001683) - 1)^2
        )
        basicallyEqual(
            a: updatedCharacter.attributes[ATTR3_NAME]!.progression,
            b: 6.1366465497 // (sqrt(12.09109769979335) - 1)^2
        )
        
        // Force baseline condition
        updatedCharacter = updatedCharacter.update(update: update, step: 100)
        basicallyEqual(
            a: updatedCharacter.attributes[ATTR1_NAME]!.progression,
            b: 1
        )
        basicallyEqual(
            a: updatedCharacter.attributes[ATTR2_NAME]!.progression,
            b: 2 
        )
        basicallyEqual(
            a: updatedCharacter.attributes[ATTR3_NAME]!.progression,
            b: 3
        )
    }
    
    func testRPGMath() {
        let testData : [(Double, Double, Double)] = [(2.0, 5.0, 10.0), (2.0, -5.0, 10.0)]
        
        testData.forEach { data in
            let exponent = RPGMath.createExponential(a: data.1, base: data.0)
            let inverseExp = RPGMath.createInverseExponential(a: data.1, base: data.0)
            
            let logarithm = RPGMath.createLogarithmic(a: data.1, base: data.0)
            let inverseLog = RPGMath.createInverseLogarithmic(a: data.1, base: data.0)
            
            let testVal : Double = data.2
            
            basicallyEqual(a: Float(inverseExp(exponent(testVal))), b: Float(testVal))
            basicallyEqual(a: Float(inverseLog(logarithm(testVal))), b: Float(testVal))
        }
    }
    
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
