//
//  Utility.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

public typealias AttributeCalculation<T : FloatingPoint> = (T) -> T

import Foundation

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return max(self.lowerBound, min(self.upperBound, value))
    }
}

public struct RPGMath {
    public static func createQuadratic<T: FloatingPoint>(a : T, b : T = 0, c : T = 0) -> AttributeCalculation<T> {
        return { x in (a * x * x) + (b * x) + c }
    }
    
    public static func createInverseQuadratic<T: FloatingPoint>(a : T, b : T = 0, c : T = 0) -> AttributeCalculation<T> {
        return { y in
            // Had to break this all up into sub expressions, because
            // the Swift type inference system was getting depressed
            // (and taking forever).
            let b2 = b * b
            let ac4 = 4 * a * (c - y)
            let b2_4ac = b2 - ac4
            let top = -b + b2_4ac.squareRoot()
            return top / (2*a)
        }
    }
    
    public static func createExponential(a : Double, base : Double) -> AttributeCalculation<Double> {
        return { x in a * pow(base, x) }
    }
    
    public static func createInverseExponential(a : Double, base : Double) -> AttributeCalculation<Double> {
        return { y in (log(y / a)) / log(base) }
    }
    
    public static func createLogarithmic(a : Double, base : Double) -> AttributeCalculation<Double> {
        return { x in a * (log(x) / log(base)) }
    }
    
    public static func createInverseLogarithmic(a : Double, base : Double) -> AttributeCalculation<Double> {
        return { y in pow(base, y / a) }
    }
}

