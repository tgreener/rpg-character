//
//  CharacterFunctions.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

#if !ECHOES
import Foundation
#endif

/// The type of a function that updates an attribute with a given step.
public typealias AttributeUpdateFunction = (AttributeValue, Float) -> AttributeValue

/// The type of a function that updates an attribute where the step is always the same.
public typealias AttributeConstantUpdateFunction = (AttributeValue) -> AttributeValue
public typealias AttributeUpdateCalculation = AttributeCalculation<Double>

/// A namespace that has functions for creating AttributeUpdateFunctions
/// Note: "Updates" can be in any direction
public struct AttributeUpdateFunctions {
    // Generalized function algorithms. User friendly!

    /**
     Create an update function from a given calculation and its inverse.
     - Parameter pair: The function and inverse tuple that describes how the attribute progresses.
        Maps from an abstract base value to progression.
     - Returns: A function that takes an attribute and a "step" (change in abstract base units),
        and returns a new updated attribute.
     */
    public static func createUpdateFunction(pair: RPGMath.FunctionInversePair<Double>) -> AttributeUpdateFunction {
        return createUpdateFunction(function: pair.function, inverseFunction: pair.inverse)
    }
    
    /**
     Create an update function from a given calculation and its inverse that has the same update applied every time.
     - Parameter pair: The function and inverse tuple that describes how the attribute progresses.
         Maps from an abstract base value to progression.
     - Parameter step: The constant step that is applied every time. The step is the change in the abstract base of the
        growth function.
     - Returns: A function that takes an attribute, and returns a new updated attribute.
     */
    public static func createConstantUpdateFunction(pair: RPGMath.FunctionInversePair<Double>, step: Float) -> AttributeConstantUpdateFunction {
        return createConstantUpdateFunction(function: pair.function, inverseFunction: pair.inverse, step: step)
    }
    
    /**
     Create an update function that decays to baseline from a given calculation and its inverse.
     - Parameter pair: The function and inverse tuple that describes how the attribute progresses.
        Maps from an abstract base value to progression.
     - Returns: A function that takes an attribute and a "step" (change in abstract base units),
        and returns a new updated attribute.
     */
    public static func createDecayFunction(pair: RPGMath.FunctionInversePair<Double>) -> AttributeUpdateFunction {
        return createDecayFunction(function: pair.function, inverseFunction: pair.inverse)
    }
    
    /**
     Create a decay to baseline function from a given calculation and its inverse that applies the same decay step every time.
     - Parameter pair: The function and inverse tuple that describes how the attribute progresses.
         Maps from an abstract base value to progression.
     - Parameter step: The constant step that is applied every time. The step is the change in the abstract base of the
        growth function.
     - Returns: A function that takes an attribute, and returns a new updated attribute.
     */
    public static func createConstantDecayFunction(pair: RPGMath.FunctionInversePair<Double>, step: Float) -> AttributeConstantUpdateFunction {
        return createConstantDecayFunction(function: pair.function, inverseFunction: pair.inverse, step: step)
    }
    
    /**
     Create an update function from a given calculation and its inverse.
     - Parameter function: The function that describes how the attribute progresses.
        Maps from an abstract base value to progression.
     - Parameter inverseFunction: The inverse of `function`. Maps from progression to an abstract base value.
     - Returns: A function that takes an attribute and a "step" (change in abstract base units),
        and returns a new updated attribute.
     
     NOTE: `function` and `inverseFunction` must be true inverses for the returned update function to behave properly
     */
    public static func createUpdateFunction(function : @escaping AttributeUpdateCalculation, inverseFunction : @escaping AttributeUpdateCalculation) -> AttributeUpdateFunction {
        return { attribute, step in
            createConstantUpdateFunction(function: function, inverseFunction: inverseFunction, step: step)(attribute)
        }
    }

    /**
     Create an update function from a given calculation and its inverse that has the same update applied every time.
     - Parameter function: The function that describes how the attribute progresses.
         Maps from an abstract base value to progression.
     - Parameter inverseFunction: The inverse of `function`. Maps from progression to an abstract base value.
     - Parameter step: The constant step that is applied every time. The step is the change in the abstract base of the
        growth function.
     - Returns: A function that takes an attribute, and returns a new updated attribute.
     
     NOTE: `function` and `inverseFunction` must be true inverses for the returned update function to behave properly
     */
    public static func createConstantUpdateFunction(function : @escaping AttributeUpdateCalculation, inverseFunction : @escaping AttributeUpdateCalculation, step : Float) -> AttributeConstantUpdateFunction {
        return { attribute in
            let base = Float(inverseFunction(Double(attribute.progression)))
            let updatedBase = base + step
            let updatedProgress = Float(function(Double(updatedBase)))
            let result = clampUpdatedValueToBaseline(current: attribute.progression, updated: updatedProgress, baseline: attribute.baseline)

            return RPGAttribute(attribute: attribute, progression: result)
        }
    }

    /**
     Create an update function that decays to baseline from a given calculation and its inverse.
     - Parameter function: The function that describes how the attribute progresses.
         Maps from an abstract base value to progression.
     - Parameter inverseFunction: The inverse of `function`. Maps from an abstract base value to progression.
     - Returns: A function that takes an attribute and a "step" (change in abstract base units),
         and returns an attribute whose progression is closer to baseline than the input.
     
     NOTE: `function` and `inverseFunction` must be true inverses for the returned update function to behave properly
     */
    public static func createDecayFunction(function : @escaping AttributeUpdateCalculation, inverseFunction : @escaping AttributeUpdateCalculation) -> AttributeUpdateFunction {
        return { attribute, step in
            createConstantDecayFunction(function: function, inverseFunction: inverseFunction, step: step)(attribute)
        }
    }

    /**
     Create a decay to baseline function from a given calculation and its inverse that applies the same decay step every time.
     - Parameter function: The function that describes how the attribute progresses. Maps from an abstract base value to progression.
     - Parameter inverseFunction: The inverse of `function`. Maps from an abstract base value to progression.
     - Parameter step: The constant step that is applied every time. The step is the change in the abstract base of the growth function.
     - Returns: A function that takes an attribute, and returns an attribute whose progression is closer to baseline than the input.
     
     NOTE: `function` and `inverseFunction` must be true inverses for the returned update function to behave properly
     */
    public static func createConstantDecayFunction(function : @escaping AttributeUpdateCalculation, inverseFunction : @escaping AttributeUpdateCalculation, step : Float) -> AttributeConstantUpdateFunction {
        return { attribute in
            let currentTime = Float(inverseFunction(Double(attribute.progression)))
            let baselineTime = Float(inverseFunction(Double(attribute.baseline)))
            let direction : Float = currentTime >= baselineTime ? -1 : 1

            return createConstantUpdateFunction(function: function, inverseFunction: inverseFunction, step: step * direction)(attribute)
        }
    }

    // Convenience methods for creating linear growth functions. Linear functions are special cases that don't
    // require the function/inverse algorithm to work, and in fact, are simpler to understand without it.


    /**
     Create an attribute update function with a linear change.
     - Parameter coefficient: The linear rate of change.
     - Returns: A function that takes an attribute and step, and returns an updated attribute.
     */
    public static func linearGrowth(coefficient : Float) -> AttributeUpdateFunction {
        return { attribute, step in
            return AttributeUpdateFunctions.linearGrowthCalculation(
                attribute: attribute,
                step: step,
                coefficient: coefficient
            )
        }
    }

    /**
     Create an attribute update function with a linear change that always uses the same step.
     - Parameter coefficient: The linear rate of change.
     - Parameter step: The magnitude of the update to apply.
     - Returns: A function that takes an attribute, and returns an updated attribute.
     */
    public static func constantLinearGrowth(coefficient : Float, step: Float) -> AttributeConstantUpdateFunction {
        return { attribute in
            return AttributeUpdateFunctions.linearGrowthCalculation(
                attribute: attribute,
                step: step,
                coefficient: coefficient
            )
        }
    }

    private static func linearGrowthCalculation(
        attribute: AttributeValue,
        step: Float,
        coefficient : Float) -> AttributeValue
    {
        let progression = attribute.progression + (coefficient * step)
        return RPGAttribute (attribute: attribute, progression: progression)
    }


    /**
     Convenience method for creating a logarithmic growth update function.
     - Parameter a: A coefficient that's applied to the result of the logarithm.
     - Parameter base: The logarithmic base. Defaults to *e*.
     - Returns: A function that takes an attribute and a step, and returns an updated attribute.
     */
    public static func logarithmicGrowth(a : Double, base : Double = M_E) -> AttributeUpdateFunction {
        createUpdateFunction(pair: RPGMath.createLogarithmicPair(a: a, base: base))
    }

    /**
     Convenience method for creating a logarithmic growth function that has the same update step every time.
     - Parameter a: A coefficient that's applied to the result of the logarithm.
     - Parameter base: The logarithmic base. Defaults to *e*.
     - Parameter step: The magnitude of the update to apply.
     - Returns: A function that takes an attribute, and returns an updated attribute.
     */
    public static func constantLogarithmicGrowth(a : Double, base : Double, step : Float) -> AttributeConstantUpdateFunction {
        createConstantUpdateFunction(pair: RPGMath.createLogarithmicPair(a: a, base: base), step: step)
    }

    /**
     Convenience method for creating a root growth update function.
     - Parameter a: A coefficient that's applied under the root function.
     - Parameter root: The root magnitude.
     - Returns: A function that takes an attribute and a step, and returns an updated attribute.
     */
    public static func rootGrowth(a : Double, root : Double) -> AttributeUpdateFunction{
        createUpdateFunction(pair: RPGMath.createRootPair(a: a, root: root))
    }

    /**
     Convenience method for creating a root growth update function.
     - Parameter a: A coefficient that's applied under the root function.
     - Parameter root: The root magnitude.
     - Parameter step: The magnitude of the update to apply.
     - Returns: A function that takes an attribute, and returns an updated attribute.
     */
    public static func constantRootGrowth(a : Double, root : Double, step : Float) -> AttributeConstantUpdateFunction {
        createConstantUpdateFunction(pair: RPGMath.createRootPair(a: a, root: root), step: step)
    }

    /**
     Create an update function that decays to baseline from a given calculation and its inverse.
     - Parameter slope: The rate of change for the decay.
     - Returns: A function that takes an attribute and a step, and returns an attribute whose progression is closer to baseline than the input.
     */
    public static func linearDecay(slope : Float) -> AttributeUpdateFunction {
        return { attribute, dt in
            let direction : Float = attribute.progression >= attribute.baseline ? -1 : 1
            let progression = attribute.progression + ((slope * dt)  * direction)
            let result = clampUpdatedValueToBaseline(current: attribute.progression, updated: progression, baseline: attribute.baseline)

            return RPGAttribute(attribute: attribute, progression: result)
        }
    }

    /**
     Create an update function that decays to baseline from a given calculation and its inverse.
     - Parameter a: The coefficient of power 2 part of the quadratic function.
     - Parameter b: The coefficient of power 1 part of the quadratic function.
     - Returns: A function that takes an attribute and a step, and returns an attribute whose progression is closer to baseline than the input.
     */
    public static func quadraticDecay(a : AttributeProgressionType, b : AttributeProgressionType) -> AttributeUpdateFunction {
        createDecayFunction(pair: RPGMath.createQuadraticPair(a: Double(a), b: Double(b)))
    }

    /**
     Create an update function that decays to baseline from a given calculation and its inverse.
     - Parameter a: A coefficient applied after performing the power function.
     - Parameter power: The power that is applied to the base value.
     - Returns: A function that takes an attribute and a step, and returns an attribute whose progression is closer to baseline than the input.
     */
    public static func powerDecay(a : AttributeProgressionType, power : AttributeProgressionType) -> AttributeUpdateFunction {
        createDecayFunction(pair: RPGMath.createPowerPair(a: Double(a), power: Double(power)))
    }

    /**
     Create an update function that decays to baseline from a given calculation and its inverse.
     - Parameter a: A coefficient applied after performing the exponential function.
     - Parameter base: The base of the exponent. Defaults to *e*.
     - Returns: A function that takes an attribute and a step, and returns an attribute whose progression is closer to baseline than the input.
     */
    public static func exponentialDecay(a : AttributeProgressionType, base : AttributeProgressionType = Float(M_E)) -> AttributeUpdateFunction {
        createDecayFunction(pair: RPGMath.createExponentialPair(a: Double(a), base: Double(base)))
    }
}

/// Convenience methods for creating level functions.
public struct AttributeLevelSystems {
    /// Create a level system that always returns zero.
    public static func zeroed() -> AttributeLevelSystem {
        return RPGAttributeLevelSystem(
            levelFunction: { _ in 0 },
            inverseLevelFunction: { _ in 0 }
        )
    }

    /**
     Create a level system where progression maps to levels in a linear way.
     - Parameter slope: The rate of change of the linear function.
     - Parameter offset: b in y = ax + b
     - Returns: A linear level system.
     */
    public static func linearLevelSystem(slope : AttributeProgressionType, offset : AttributeProgressionType = 0.0) -> AttributeLevelSystem {
        return RPGAttributeLevelSystem(
            levelFunction: { progress in Int(floorf((progress - offset) / slope)) + 1 },
            inverseLevelFunction: { level in (Float(level - 1) * slope) + offset }
        )
    }

    /**
     Create a level system where progression maps to levels in a quadratic way.
     - Parameter a: a in y = ax^2 + bx + c
     - Parameter b: b in y = ax^2 + bx + c
     - Parameter c: c in y = ax^2 + bx + c
     - Returns: A quadratic level system.
     */
    public static func quadraticLevelSystem(a : AttributeProgressionType, b : AttributeProgressionType = 0.0, c : AttributeProgressionType = 0.0) -> AttributeLevelSystem {
        guard a != 0 else {
            return AttributeLevelSystems.linearLevelSystem(slope: b, offset: c)
        }

        return AttributeLevelSystems.createLevelSystem(
            function: RPGMath.createQuadratic(a: a, b: b, c: c),
            inverse: RPGMath.createInverseQuadratic(a: a, b: b, c: c)
        )
    }

    /**
     Create a level system where progression maps to levels following an exponential curve.
     - Parameter a: a in y = a * base^x
     - Parameter base: base in y = a * base^x
     - Returns: An exponential level system.
     */
    public static func exponentialLevelSystem(a : AttributeProgressionType = 1.0, base : AttributeProgressionType = Float(M_E)) -> AttributeLevelSystem {
        return AttributeLevelSystems.createLevelSystem(
            function: RPGMath.createExponential(a: Double(a), base: Double(base)),
            inverse: RPGMath.createInverseExponential(a: Double(a), base: Double(base))
        )
    }

    /**
     Create a level system where progression maps to levels following a power curve.
     - Parameter a: a in y = a * x^power
     - Parameter power: base in y = a * x^power
     - Returns: A power level system.
     */
    public static func powerLeveSystem(a : AttributeProgressionType, power : AttributeProgressionType) -> AttributeLevelSystem {
        return AttributeLevelSystems.createLevelSystem(
            function: RPGMath.createPower(a: Double(a), power: Double(power)),
            inverse: RPGMath.createInversePower(a: Double(a), power: Double(power))
        )
    }

    /**
     Create a level system where progression maps to levels as defined by the provided functions.
     - Parameter function: A function that defines the shape of the level curve. f(x)
     - Parameter inverse: The inverse of `function`. g(x) such that (g o f)(x) = x
     - Returns: A level system based on the provided functions.
     */
    public static func createLevelSystem(function: @escaping AttributeCalculation<Float>, inverse: @escaping AttributeCalculation<Float>) -> AttributeLevelSystem {
        return RPGAttributeLevelSystem(
            levelFunction: { progress in
                let floatingResult = inverse(progress)
                return 1 + Int(floorf(floatingResult))
            },
            inverseLevelFunction: { level in
                return function(Float(level - 1))
            }
        )
    }

    /**
     Create a level system where progression maps to levels as defined by the provided functions.
     - Parameter function: A function that defines the shape of the level curve. f(x)
     - Parameter inverse: The inverse of `function`. g(x) such that (g o f)(x) = x
     - Returns: A level system based on the provided functions.
     */
    public static func createLevelSystem(function: @escaping AttributeCalculation<Double>, inverse: @escaping AttributeCalculation<Double>) -> AttributeLevelSystem {
        return RPGAttributeLevelSystem(
            levelFunction: { progress in
                let floatingResult = inverse(Double(progress))
                return 1 + Int(floor(floatingResult))
            },
            inverseLevelFunction: { level in
                return Float(function(Double(level - 1)))
            }
        )
    }
}
