//
//  RPGMath-Apple.swift
//  RPG Character
//
//  Created by Todd Greener on 7/15/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public typealias AttributeCalculation<T : FloatingPoint> = (T) -> T

public extension RPGMath {
    /**
     Create a calculation function of the form: `y = ax^2 + bx + c`
     - Parameter a: Coefficient applied to the squared value and added to bx + c.
     - Parameter b: Coefficient applied to the value and added to ax^2 + c.
     - Parameter c: Constant value added to ax^2 + bx.
     - Returns: A function that performs the quadratic calculation.
     */
    static func createQuadratic<T: FloatingPoint>(a : T, b : T = 0, c : T = 0) -> AttributeCalculation<T> {
        return { x in (a * x * x) + (b * x) + c }
    }
    
    /**
     Create a calculation function in the form of the quadratic formula (inverse quadratic).
     - Parameter a: All over 2a. See quadratic formula.
     - Parameter b: Used in a couple different places in the quadratic formula.
     - Parameter c: See quadratic formula.
     - Returns: A function that performs the inverse quadratic calculation.
     */
    static func createInverseQuadratic<T: FloatingPoint>(a : T, b : T = 0, c : T = 0) -> AttributeCalculation<T> {
        return { y in
            // Had to break this all up into sub expressions, because
            // the Swift type inference system was getting depressed
            // (and taking forever).
            let b2 : T = b * b
            let ac4 : T = 4 * a * (c - y)
            let sqrt_b2_4ac : T = (b2 - ac4).squareRoot()
            let top : T = -b + sqrt_b2_4ac
            return top / (2*a)
        }
    }
    
    static let nan : Double = Double.nan
}

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return Swift.max(self.lowerBound, Swift.min(self.upperBound, value))
    }
}

func clampUpdatedValueToBaseline(current : AttributeProgressionType, updated : AttributeProgressionType, baseline : AttributeProgressionType) -> AttributeProgressionType {
    let allowedRange = current > updated ? (baseline...Float.infinity) : (-Float.infinity...baseline)
    return allowedRange.clamp(updated)
}
