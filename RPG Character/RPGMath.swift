//
//  Utility.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

#if !ECHOES
import Foundation
#endif

/// Namespace for creating mathematic functions to use in calculating character updates.
///
/// It is useful to remember that  (f o g)^-1(x) = (g^-1 o f^-1)(x), or the inverse of a composition
/// of f and g is the inverse of g composed with the inverse of f.
///
/// This means that any composition of the following functions can be used in a growth/decay or
/// level system by using the above formula to find the composed function's inverse.
public struct RPGMath {
    public typealias FunctionInversePair<T: FloatingPoint> = (function: AttributeCalculation<T>, inverse: AttributeCalculation<T>)
    
    /// Composes a list of functions together, left to right. Composing the inverse functions first reverses the list and then composes them.
    /// This should work if the domain and codomain of all composed functions are the same.
    /// - Parameter functions: The functions to be composed together
    /// - Returns: The function and its inverse composed together.
    public static func compose<T: FloatingPoint>(functions: [FunctionInversePair<T>])  -> FunctionInversePair<T> {
        let identity: AttributeCalculation<T> = {$0}
        
        let composition = { (f: @escaping AttributeCalculation<T>, g: @escaping AttributeCalculation<T>) in { (x: T) in f(g(x)) } }
        
        let resultFunction = functions.map { $0.function }.reduce(identity, composition)
        let resultInverse = functions.map { $0.inverse }.reversed().reduce(identity, composition)
        
        return (resultFunction, resultInverse)
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
        return { y in
            (base != 0.0 && y != 0.0 && base != 1) ?
                (log(y / a)) / log(base) :
                RPGMath.nan
        }
    }

    /**
     Create a calculation function of the form: `y = a * base^x` and its inverse: `y = log_base_(x / a)`
     - Parameter a: Coefficient divided from the value before the inverse exponent (logarithm) function.
     - Parameter base: The base of the inverse exponent (logarithm). Defaults to *e*.
     - Returns: A pair of functions that performs the inverse exponential calculation and its inverse.
     */
    public static func createExponentialPair(a : Double, base : Double = M_E) -> FunctionInversePair<Double> {
        return (createExponential(a: a, base: base), createInverseExponential(a: a, base: base))
    }
    
    /**
     Create a calculation function of the form: `y = a * log_base_(x)`
     - Parameter a: Coefficient applied to the result of the logarithm.
     - Parameter base: The base of the logarithm. Defaults to *e*.
     - Returns: A function that performs the logarithmic calculation.
     */
    public static func createLogarithmic(a : Double = 1.0, base : Double = M_E) -> AttributeCalculation<Double> {
        return { x in
            (base != 0.0 && x != 0.0 && base != 1) ?
                a * (log(x) / log(base)) :
                RPGMath.nan
        }
    }

    /**
     Create a calculation function of the form: `y = a * log_base_(x)`
     - Parameter a: Coefficient divided from the given value (exponent).
     - Parameter base: The base of the inverse log (exponent). Defaults to *e*.
     - Returns: A function that performs the inverse logarithmic calculation.
     */
    public static func createInverseLogarithmic(a : Double = 1.0, base : Double = M_E) -> AttributeCalculation<Double> {
        return { y in pow(base, y / a) }
    }
    
    /**
     Create a calculation function of the form: `y = a * log_base_(x)`and its inverse
     - Parameter a: Coefficient applied to the result of the logarithm.
     - Parameter base: The base of the logarithm. Defaults to *e*.
     - Returns: A pair of functions that performs the logarithmic calculation and its inverse.
     */
    public static func createLogarithmicPair(a : Double = 1.0, base : Double = M_E) -> FunctionInversePair<Double> {
        return (createLogarithmic(a: a, base: base), createInverseLogarithmic(a: a, base: base))
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
    public static func createInversePower(a : Double, power : Double) -> AttributeCalculation<Double> {
        return { y in power != 0 && a != 0 && y >= 0 ?
            pow((y / a), (1/power)) :
            RPGMath.nan
        }
    }
    
    /**
     Create a calculation function of the form: `y = a * x^power` and its inverse
     - Parameter a: Coefficient applied to the result of the power function.
     - Parameter power: The magnitude of the power function.
     - Returns: A pair of functions that performs the power calculation and its inverse.
     */
    public static func createPowerPair(a : Double, power : Double) -> FunctionInversePair<Double> {
        return (createPower(a: a, power: power), createInversePower(a: a, power: power))
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
        return { x in root != 0 && x >= 0 ? pow(a * x, 1 / root) : RPGMath.nan }
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
        return { y in a != 0 ? pow(y, root) / a : RPGMath.nan }
    }
    
    /**
     Create a calculation function of the form: y = (a * x)^(1 / root) and its inverse
     Very similar to inverse power function; which you choose depends on how you
     like to think about it.
     - Parameter a: A coefficient multiplied under/before the root function.
     - Parameter root: The magnitude of the root being applied.
     - Returns: A a pair of functions that performs the root calculation and its inverse.
     */
    public static func createRootPair(a : Double, root : Double) -> FunctionInversePair<Double> {
        return (createRoot(a: a, root: root), createInverseRoot(a: a, root: root))
    }
}
