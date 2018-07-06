//
//  Utility.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public typealias AttributeCalculation<T : FloatingPoint> = (T) -> T

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return max(self.lowerBound, min(self.upperBound, value))
    }
}

/// Namespace for creating mathematic functions to use in calculating character updates.
public struct RPGMath {
    /**
     Create a calculation function of the form: `y = ax^2 + bx + c`
     - Parameter a: Coefficient applied to the squared value and added to bx + c.
     - Parameter b: Coefficient applied to the value and added to ax^2 + c.
     - Parameter c: Constant value added to ax^2 + bx.
     - Returns: A function that performs the quadratic calculation.
     */
    public static func createQuadratic<T: FloatingPoint>(a : T, b : T = 0, c : T = 0) -> AttributeCalculation<T> {
        return { x in (a * x * x) + (b * x) + c }
    }
    
    /**
     Create a calculation function in the form of the quadratic formula (inverse quadratic).
     - Parameter a: All over 2a. See quadratic formula.
     - Parameter b: Used in a couple different places in the quadratic formula.
     - Parameter c: See quadratic formula.
     - Returns: A function that performs the inverse quadratic calculation.
     */
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
    
    /**
     Create a calculation function of the form: `y = a * base^x`
     - Parameter a: Coefficient applied to the result of the exponent function.
     - Parameter base: The base of the exponent. Defaults to *e*.
     - Returns: A function that performs the exponential calculation.
     */
    public static func createExponential(a : Double, base : Double = M_E) -> AttributeCalculation<Double> {
        return { x in a * pow(base, x) }
    }
    
    /**
     Create a calculation function of the form: `y = log_base_(x / a)`
     - Parameter a: Coefficient divided from the value before the inverse exponent (logarithm) function.
     - Parameter base: The base of the inverse exponent (logarithm). Defaults to *e*.
     - Returns: A function that performs the inverse exponential calculation.
     */
    public static func createInverseExponential(a : Double, base : Double = M_E) -> AttributeCalculation<Double> {
        return { y in (log(y / a)) / log(base) }
    }
    
    /**
     Create a calculation function of the form: `y = a * log_base_(x)`
     - Parameter a: Coefficient applied to the result of the logarithm.
     - Parameter base: The base of the logarithm. Defaults to *e*.
     - Returns: A function that performs the logarithmic calculation.
     */
    public static func createLogarithmic(a : Double, base : Double = M_E) -> AttributeCalculation<Double> {
        return { x in a * (log(x) / log(base)) }
    }
    
    /**
     Create a calculation function of the form: `y = a * log_base_(x)`
     - Parameter a: Coefficient divided from the given value (exponent).
     - Parameter base: The base of the inverse log (exponent). Defaults to *e*.
     - Returns: A function that performs the inverse logarithmic calculation.
     */
    public static func createInverseLogarithmic(a : Double, base : Double = M_E) -> AttributeCalculation<Double> {
        return { y in pow(base, y / a) }
    }
    
    /**
     Create a calculation function of the form: `y = a * x^power`
     - Parameter a: Coefficient applied to the result of the power function.
     - Parameter power: The magnitude of the power function.
     - Returns: A function that performs the power calculation.
     */
    public static func createPower(a : Double, power : Double) -> AttributeCalculation<Double> {
        return { x in a * pow(x, power) }
    }
    
    /**
     Create a calculation function of the form: x = (y / a)^(1 / power)
     - Parameter a: The coefficient that the input is divided by before applying the inverse power (root).
     - Parameter power: The magnitude of the inverse power (root) function.
     - Returns: A function that performs the inverse power calculation.
     */
    public static func createInvsersePower(a : Double, power : Double) -> AttributeCalculation<Double> {
        return { y in pow((y / a), (1/power)) }
    }
    
    /**
     Create a calculation function of the form: y = (a * x)^(1 / root)
     Very similar to inverse power function; which you choose depends on how you
     like to think about it.
     - Parameter a: A coefficient multiplied under/before the root function.
     - Parameter root: The magnitude of the root being applied.
     - Returns: A function that performs the root calculation.
     */
    public static func createRoot(a : Double, root : Double) -> AttributeCalculation<Double> {
        return { x in pow(a * x, 1 / root) }
    }
    
    /**
     Create a calculation function of the form: x = (y^root) / a
     Very similar to power function; which you choose depends on how you
     like to think about it.
     - Parameter a: A coefficient, divided after the inverse root (power) is calculated.
     - Parameter root: The magnitude of the inverse root (power) being applied.
     - Returns: A function that performs the inverse root calculation.
     */
    public static func createInverseRoot(a : Double, root : Double) -> AttributeCalculation<Double> {
        return { y in pow(y, root) / a }
    }
}

