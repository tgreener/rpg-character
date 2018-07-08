//
//  RPG_AttributeTests.swift
//  RPG CharacterTests
//
//  Created by Todd Greener on 7/8/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import XCTest

class RPG_AttributeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testZeroedLevelSystem() {
        let levelSystem = AttributeLevelSystems.zeroed()
        (0...100).forEach { XCTAssert(levelSystem.levelFunction(Float($0)) == 0) }
        (1...100).forEach { XCTAssert(levelSystem.inverseLevelFunction($0) == 0) }
    }
    
    func testLinearLevelSystem() {
        let levelSystem = AttributeLevelSystems.linearLevelSystem(slope: 1)
        (0...100).forEach { XCTAssertEqual(levelSystem.levelFunction(Float($0)), $0 + 1) }
        (1...100).forEach { XCTAssertEqual(levelSystem.inverseLevelFunction($0), Float($0 - 1)) }
        
        let levelSystem2 = AttributeLevelSystems.linearLevelSystem(slope: 10)
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
    
}
