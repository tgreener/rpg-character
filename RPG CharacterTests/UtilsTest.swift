//
//  UtilsTest.swift
//  RPG CharacterTests
//
//  Created by Todd Greener on 7/8/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import XCTest
@testable import RPG_Character

typealias FunctionInput = Float
typealias FunctionOutput = Float
typealias FunctionTestCases = [(FunctionInput, FunctionOutput)]
typealias FunctionTestParameter = Float

class UtilsTest: XCTestCase {
    /// Test parameters for trying out all functions. Must be non-negative, as
    /// several of the functions testing here, only make sense if given positive
    /// values.
    private static let TEST_PARAMS : [Float] = [
        0.0, 0.5, 1.0, 5.0
    ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testQuadraticMath() {
        typealias QuadraticFunctionTestParameters = [(FunctionTestParameter, FunctionTestParameter, FunctionTestParameter, FunctionTestCases)]
        
        let functionParams : QuadraticFunctionTestParameters = [
            // Simplest quadratic: x^2
            ( 1.0, 0.0, 0.0, [
                (1.0, 1.0),
                (2.0, 4.0),
                (3.0, 9.0),
                (4.0, 16.0),
                (0.0, 0.0),
                (-1.0, 1.0),
                (0.5, 0.25),
                (-0.5, 0.25),
                (0.25, 0.0625),
            ]),
            
            // Simple quadratic: 2x^2
            ( 2.0, 0.0, 0.0, [
                (1.0, 2.0),
                (2.0, 8.0),
                (3.0, 18.0),
                (4.0, 32.0),
                (0.0, 0.0),
                (-1.0, 2.0),
                (0.5, 0.5),
                (-0.5, 0.5),
                (0.25, 0.125),
            ]),
            
            // Simple quadratic: x^2 + x
            ( 1.0, 1.0, 0.0, [
                (1.0, 2.0),
                (2.0, 6.0),
                (3.0, 12.0),
                (4.0, 20.0),
                (5.0, 30.0),
                (0.0, 0.0),
                (-1.0, 0.0),
                (0.5, 0.75),
                (-0.5, -0.25),
                (0.25, 0.3125),
            ]),
            
            // Simple quadratic: x^2 + x + 10
            ( 1.0, 1.0, 10.0, [
                (1.0, 12.0),
                (2.0, 16.0),
                (3.0, 22.0),
                (4.0, 30.0),
                (5.0, 40.0),
                (0.0, 10.0),
                (-1.0, 10.0),
                (0.5, 10.75),
                (-0.5, 9.75),
                (0.25, 10.3125),
            ])
        ]
        
        functionParams.map { tuple in (
            RPGMath.createQuadratic(a: tuple.0, b: tuple.1, c: tuple.2),
            RPGMath.createInverseQuadratic(a: tuple.0, b: tuple.1, c: tuple.2),
            tuple.3
        )}
        .forEach { testTuple in
            let quadratic = testTuple.0
            let inverse = testTuple.1
            let cases = testTuple.2
            
            UtilsTest.TEST_PARAMS.forEach { param in
                // Have to use absolute value, because sign info is lost during calculation.
                // This is just the nature of the thing, and not worth crying over... Probably.
                XCTAssertEqual(abs(inverse(quadratic(param))), abs(param), accuracy : 0.0001)
            }
            
            cases.forEach { testCase in
                let input = testCase.0
                let expected = testCase.1
                
                XCTAssertEqual(quadratic(input), expected, accuracy : 0.0001)
            }
        }
    }
    
    func testExponentMath() {
        typealias ExponentFunctionTestParameters = [(FunctionTestParameter, FunctionTestParameter, FunctionTestCases)]
        
        let functionParams : ExponentFunctionTestParameters = [
            // Simple exponent: 0^x
            ( 1.0, 0.0, [
                (1.0, 0.0),
                (2.0, 0.0),
                (3.0, 0.0),
                (4.0, 0.0),
                (0.0, 1.0),
                (0.5, 0.0),
                (0.25, 0.0),
            ]),
            
            // Simple exponent: 1^x
            ( 1.0, 1.0, [
                (1.0, 1.0),
                (2.0, 1.0),
                (3.0, 1.0),
                (4.0, 1.0),
                (0.0, 1.0),
                (0.5, 1.0),
                (0.25, 1.0),
            ]),
            
            // Simple exponent: 2^x
            ( 1.0, 2, [
                (1.0, 2.0),
                (2.0, 4.0),
                (3.0, 8.0),
                (4.0, 16.0),
                (0.0, 1.0),
                (-1.0, 0.5),
                (0.5, 1.41421),
                (-0.5, 0.707105),
                (0.25, 1.18920),
            ]),
            
            // Simple exponent: 5 * 2^x
            ( 5.0, 2.0, [
                (1.0, 10.0),
                (2.0, 20.0),
                (3.0, 40.0),
                (4.0, 80.0),
                (0.0, 5.0),
                (-1.0, 2.5),
                (0.5, 7.071067),
                (-0.5, 3.535533),
                (0.25, 5.94603),
            ])
        ]
        
        functionParams.map { tuple in (
            RPGMath.createExponential(a: Double(tuple.0), base: Double(tuple.1)),
            RPGMath.createInverseExponential(a: Double(tuple.0), base: Double(tuple.1)),
            tuple.2,
            tuple.1
        )}
        .forEach { testTuple in
            let exponential = testTuple.0
            let inverse = testTuple.1
            let cases = testTuple.2
            let base = testTuple.3
            
            UtilsTest.TEST_PARAMS.forEach { param in
                let result = exponential(Double(param))
                let canInvert = result != 0.0 && base != 0.0 && base != 1
                
                guard canInvert else {
                    let assertThis = inverse(result)
                    XCTAssert(assertThis.isNaN, "Inverse exponent with base (\(base)) and param (\(result)) should be NaN, but is instead \(assertThis)")
                    return
                }
                
                XCTAssertEqual(inverse(result), Double(param), accuracy : 0.0001)
            }
            
            cases.forEach { testCase in
                let input = testCase.0
                let expected = testCase.1
                
                XCTAssertEqual(exponential(Double(input)), Double(expected), accuracy : 0.0001)
            }
        }
    }
    
    func testLogarithmMath() {
        typealias LogarithmFunctionTestParameters = [(FunctionTestParameter, FunctionTestParameter, FunctionTestCases)]
        
        let functionParams : LogarithmFunctionTestParameters = [
            // Simple exponent: log_0_(x)
            ( 1.0, 0.0, [
                (1.0, Float.nan),
                (2.0, Float.nan),
                (3.0, Float.nan),
                (4.0, Float.nan),
                (0.0, Float.nan),
                (0.5, Float.nan),
                (0.25, Float.nan),
            ]),
            
            // Simple exponent: log_1_(x)
            ( 1.0, 1.0, [
                (1.0, Float.nan),
                (2.0, Float.nan),
                (3.0, Float.nan),
                (4.0, Float.nan),
                (0.0, Float.nan),
                (0.5, Float.nan),
                (0.25, Float.nan),
            ]),

            // Simple exponent: log_2_(x)
            ( 1.0, 2, [
                (1.0, logf(1.0) / logf(2.0)),
                (2.0, logf(2.0) / logf(2.0)),
                (3.0, logf(3.0) / logf(2.0)),
                (4.0, logf(4.0) / logf(2.0)),
                (0.0, Float.nan),
                (-1.0, Float.nan),
                (0.5, logf(0.5) / logf(2.0)),
                (-0.5, Float.nan),
                (0.25, logf(0.25) / logf(2.0)),
            ]),

            // Simple exponent: 5 * log_2_(x)
            ( 5.0, 2.0, [
                (1.0, 5 * logf(1.0) / logf(2.0)),
                (2.0, 5 * logf(2.0) / logf(2.0)),
                (3.0, 5 * logf(3.0) / logf(2.0)),
                (4.0, 5 * logf(4.0) / logf(2.0)),
                (0.0, Float.nan),
                (-1.0, Float.nan),
                (0.5, 5 * logf(0.5) / logf(2.0)),
                (-0.5, Float.nan),
                (0.25, 5 * logf(0.25) / logf(2.0)),
            ]),
        ]
        
        functionParams.map { tuple in (
            RPGMath.createLogarithmic(a: Double(tuple.0), base: Double(tuple.1)),
            RPGMath.createInverseLogarithmic(a: Double(tuple.0), base: Double(tuple.1)),
            tuple.2,
            tuple.1
        )}
        .forEach { testTuple in
            let logarithm = testTuple.0
            let inverse = testTuple.1
            let cases = testTuple.2
            let base = testTuple.3
            
            UtilsTest.TEST_PARAMS.forEach { param in
                let canLogarithm = param != 0.0 && base != 0.0 && base != 1
                
                guard canLogarithm else {
                    let assertThis = logarithm(Double(param))
                    XCTAssert(assertThis.isNaN, "Logarithm with base (\(base)) and param (\(param)) should be NaN, but is instead \(assertThis)")
                    return
                }
                
                let result = logarithm(Double(param))
                
                XCTAssertEqual(inverse(result), Double(param), accuracy : 0.0001)
            }
            
            cases.forEach { testCase in
                let input = testCase.0
                let expected = testCase.1
                
                guard !expected.isNaN else {
                    let assertThis = logarithm(Double(input))
                    XCTAssert(assertThis.isNaN, "Logarithm with base (\(base)) and param (\(input)) should be NaN, but is instead \(assertThis)")
                    return
                }
                
                XCTAssertEqual(logarithm(Double(input)), Double(expected), accuracy : 0.0001)
            }
        }
    }
    
    func testPowerMath() {
        typealias PowerFunctionTestParameters = [(FunctionTestParameter, FunctionTestParameter, FunctionTestCases)]
        
        let functionParams : PowerFunctionTestParameters = [
            // Simple exponent: x^0
            ( 1.0, 0.0, [
                (1.0, 1.0),
                (2.0, 1.0),
                (3.0, 1.0),
                (4.0, 1.0),
                (0.0, 1.0),
                (0.5, 1.0),
                (0.25, 1.0),
            ]),
            
            // Simple exponent: x^1
            ( 1.0, 1.0, [
                (1.0, 1.0),
                (2.0, 2.0),
                (3.0, 3.0),
                (4.0, 4.0),
                (0.0, 0.0),
                (0.5, 0.5),
                (0.25, 0.25),
            ]),

            // Simple exponent: x^2
            ( 1.0, 2.0, [
                (1.0, 1.0),
                (2.0, 4.0),
                (3.0, 9.0),
                (4.0, 16.0),
                (0.0, 0.0),
                (-1.0, 1.0),
                (0.5, 0.25),
                (-0.5, 0.25),
                (0.25, 0.0625),
            ]),

            // Simple exponent: 5 * x^2
            ( 5.0, 2.0, [
                (1.0, 5.0),
                (2.0, 20.0),
                (3.0, 45.0),
                (4.0, 80.0),
                (0.0, 0.0),
                (-1.0, 5.0),
                (0.5, 1.25),
                (-0.5, 1.25),
                (0.25, 0.3125)
             ])
        ]
        
        functionParams.map { tuple in (
            RPGMath.createPower(a: Double(tuple.0), power: Double(tuple.1)),
            RPGMath.createInversePower(a: Double(tuple.0), power: Double(tuple.1)),
            tuple.2,
            tuple.1
        )}
        .forEach { testTuple in
            let power = testTuple.0
            let inverse = testTuple.1
            let cases = testTuple.2
            let magnitude = testTuple.3
            
            UtilsTest.TEST_PARAMS.forEach { param in
                let result = power(Double(param))
                
                if magnitude == 0 {
                    let assertThis = inverse(result)
                    XCTAssert(assertThis.isNaN, "Inverse power with magnitude (\(magnitude)) and param (\(param)) should be NaN, but is instead \(assertThis)")
                    return
                }
                // Doing absolute value, because math is weird and I don't wanna figure out how to
                // test  for cube roots and junk.
                XCTAssertEqual(inverse(result), abs(Double(param)), accuracy : 0.0001)
            }
            
            cases.forEach { testCase in
                let input = testCase.0
                let expected = testCase.1

                XCTAssertEqual(power(Double(input)), Double(expected), accuracy : 0.0001)
            }
        }
    }
    
    func testRootMath() {
        typealias RootFunctionTestParameters = [(FunctionTestParameter, FunctionTestParameter, FunctionTestCases)]
        
        let functionParams : RootFunctionTestParameters = [
            // Simple root: x^1
            ( 1.0, 1.0, [
                (1.0, 1.0),
                (2.0, 2.0),
                (3.0, 3.0),
                (4.0, 4.0),
                (0.0, 0.0),
                (0.5, 0.5),
                (0.25, 0.25),
            ]),
            
            // Simple root: x^(1/2)
            ( 1.0, 2.0, [
                (1.0, 1.0),
                (2.0, powf(2, 1.0/2.0)),
                (3.0, powf(3, 1.0/2.0)),
                (4.0, 2.0),
                (0.0, 0.0),
                (-1.0, Float.nan),
                (0.5, powf(0.5, 1.0/2.0)),
                (-0.5, Float.nan),
                (0.25, powf(0.25, 1.0/2.0)),
            ]),

            // Simple root: (5 * x)^(1/2)
            ( 5.0, 2.0, [
                (1.0, powf(5.0 * 1.0, 1.0/2.0)),
                (2.0, powf(5.0 * 2.0, 1.0/2.0)),
                (3.0, powf(5.0 * 3.0, 1.0/2.0)),
                (4.0, powf(5.0 * 4.0, 1.0/2.0)),
                (0.0, 0.0),
                (-1.0, Float.nan),
                (0.5, powf(5.0 * 0.5, 1.0/2.0)),
                (-0.5, Float.nan),
                (0.25,powf(5.0 * 0.25, 1.0/2.0)),
            ])
        ]
        
        functionParams.map { tuple in (
            function: RPGMath.createRoot(a: Double(tuple.0), root: Double(tuple.1)),
            inverse: RPGMath.createInverseRoot(a: Double(tuple.0), root: Double(tuple.1)),
            cases: tuple.2,
            magnitude: tuple.1,
            coefficient: tuple.0
        )}
        .forEach { testTuple in
            let root = testTuple.function
            let inverse = testTuple.inverse
            let cases = testTuple.cases
            let magnitude = testTuple.magnitude
            let coefficient = testTuple.coefficient
            
            UtilsTest.TEST_PARAMS.forEach { param in
                let result = root(Double(param))
                
                // Doing absolute value, because math is weird and I don't wanna figure out how to
                // test for negatives in cube roots and junk.
                XCTAssertEqual(inverse(result), abs(Double(param)), accuracy : 0.0001)
            }
            
            cases.forEach { testCase in
                let input = testCase.0
                let expected = testCase.1
                
                guard !expected.isNaN else {
                    let assertThis = root(Double(input))
                    XCTAssert(assertThis.isNaN, "Root with magnitude (\(magnitude)) and param (\(input)) should be NaN, but is instead \(assertThis)")
                    return
                }
                
                XCTAssertEqual(root(Double(input)), Double(expected), accuracy : 0.0001, "Given values: f(\(input)) = (\(coefficient) * \(input))^(1.0 / \(magnitude))")
            }
        }
    }
}
