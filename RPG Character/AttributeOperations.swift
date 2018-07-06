//
//  CharacterFunctions.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public typealias AttributeUpdateFunction = (AttributeValue, Float) -> AttributeValue
public typealias AttributeConstantUpdateFunction = (AttributeValue) -> AttributeValue
public typealias AttributeUpdateCalculation = AttributeCalculation<Double>

fileprivate func clampUpdatedValueToBaseline(current : AttributeProgressionType, updated : AttributeProgressionType, baseline : AttributeProgressionType) -> AttributeProgressionType {
    let allowedRange = current > updated ? (baseline...Float.infinity) : (-Float.infinity...baseline)
    return allowedRange.clamp(updated)
}

// Note: "Updates" can be in any direction
public struct AttributeUpdateFunctions {
    // Generalized function algorithms. User friendly!
    
    /**
     * Create an update function from a given calculation and its inverse.
     */
    public static func createUpdateFunction(function : @escaping AttributeUpdateCalculation, inverseFunction : @escaping AttributeUpdateCalculation) -> AttributeUpdateFunction {
        return { attribute, step in
            createConstantUpdateFunction(function: function, inverseFunction: inverseFunction, step: step)(attribute)
        }
    }
    
    /**
     * Create an update function from a given calculation and its inverse that has the same update applied every time.
     */
    public static func createConstantUpdateFunction(function : @escaping AttributeUpdateCalculation, inverseFunction : @escaping AttributeUpdateCalculation, step : Float) -> AttributeConstantUpdateFunction {
        return { attribute in
            let time = Float(inverseFunction(Double(attribute.progression)))
            let updatedTime = time + step
            let updatedProgress = Float(function(Double(updatedTime)))
            let result = clampUpdatedValueToBaseline(current: attribute.progression, updated: updatedProgress, baseline: attribute.baseline)
            
            return RPGAttribute(attribute: attribute, progression: result)
        }
    }
    
    /**
     * Create a decay to baseline function from a given calculation and its inverse.
     */
    public static func createDecayFunctionfunction(function : @escaping AttributeUpdateCalculation, inverseFunction : @escaping AttributeUpdateCalculation) -> AttributeUpdateFunction {
        return { attribute, step in
            createConstantDecayFunctionfunction(function: function, inverseFunction: inverseFunction, step: step)(attribute)
        }
    }
    
    /**
     * Create a decay to baseline function from a given calculation and its inverse that applies the same decay step every time.
     */
    public static func createConstantDecayFunctionfunction(function : @escaping AttributeUpdateCalculation, inverseFunction : @escaping AttributeUpdateCalculation, step : Float) -> AttributeConstantUpdateFunction {
        return { attribute in
            let currentTime = Float(inverseFunction(Double(attribute.progression)))
            let baselineTime = Float(inverseFunction(Double(attribute.baseline)))
            let direction : Float = currentTime >= baselineTime ? -1 : 1
            
            return createConstantUpdateFunction(function: function, inverseFunction: inverseFunction, step: step * direction)(attribute)
        }
    }
    
    // Convenience methods for creating linear growth functions. Linear functions are special cases that don't
    // require the function/inverse algorithm to work, and in fact, are simpler to understand without it.
    
    public static func linearGrowth(coefficient : Float) -> AttributeUpdateFunction {
        return { attribute, step in
            return AttributeUpdateFunctions.linearGrowthCalculation(
                attribute: attribute,
                step: step,
                coefficient: coefficient
            )
        }
    }
    
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
    
    
    // Convenience method for creating a logarithmic growth function.
    public static func logarithmicGrowth(a : Double, base : Double = M_E) -> AttributeUpdateFunction {
        let logarithm = RPGMath.createLogarithmic(a: a, base: base)
        let inverseLog = RPGMath.createInverseLogarithmic(a: a, base: base)
        return createUpdateFunction(function: logarithm, inverseFunction: inverseLog)
    }
    
    // Convenience method for creating a logarithmic growth function that has the same updat step every time.
    public static func constantLogarithmicGrowth(a : Double, base : Double, step : Float) -> AttributeConstantUpdateFunction {
        let logarithm = RPGMath.createLogarithmic(a: a, base: base)
        let inverseLog = RPGMath.createInverseLogarithmic(a: a, base: base)
        return createConstantUpdateFunction(function: logarithm, inverseFunction: inverseLog, step: step)
    }
    
    // Decays value toward baseline, this can be a positive or negative change
    public static func linearDecay(slope : Float) -> AttributeUpdateFunction {
        return { attribute, dt in
            let direction : Float = attribute.progression >= attribute.baseline ? -1 : 1
            let progression = attribute.progression + ((slope * dt)  * direction)
            let result = clampUpdatedValueToBaseline(current: attribute.progression, updated: progression, baseline: attribute.baseline)
            
            return RPGAttribute(attribute: attribute, progression: result)
        }
    }
    
    public static func quadraticDecay(a : AttributeProgressionType, b : AttributeProgressionType) -> AttributeUpdateFunction {
        let quadratic = RPGMath.createQuadratic(a: Double(a), b: Double(b))
        let inverseQuad = RPGMath.createInverseQuadratic(a: Double(a), b: Double(b))
        return createDecayFunctionfunction(function: quadratic, inverseFunction: inverseQuad)
    }
    
    public static func powerDecay(a : AttributeProgressionType, power : AttributeProgressionType) -> AttributeUpdateFunction {
        let powerFunction = RPGMath.createPower(a: Double(a), power: Double(power))
        let inversePower = RPGMath.createInvsersePower(a: Double(a), power: Double(power))
        return createDecayFunctionfunction(function: powerFunction, inverseFunction: inversePower)
    }
    
    public static func exponentialDecay(a : AttributeProgressionType, base : AttributeProgressionType = Float(M_E)) -> AttributeUpdateFunction {
        let exponent = RPGMath.createExponential(a: Double(a), base: Double(base))
        let inverse = RPGMath.createInverseExponential(a: Double(a), base: Double(base))
        return createDecayFunctionfunction(function: exponent, inverseFunction: inverse)
    }
}

public struct AttributeLevelSystems {
    // Create a level system that always returns zero. Used as an error case.
    public static func zeroed() -> AttributeLevelSystem {
        return RPGAttributeLevelSystem(
            levelFunction: { _ in 0 },
            inverseLevelFunction: { _ in 0 }
        )
    }
    
    public static func linearLevelSystem(step : AttributeProgressionType, offset : AttributeProgressionType = 0.0) -> AttributeLevelSystem {
        return RPGAttributeLevelSystem(
            levelFunction: { progress in Int(floorf((progress - offset) / step)) + 1 },
            inverseLevelFunction: { level in (Float(level - 1) * step) + offset }
        )
    }
    
    public static func quadraticLevelSystem(a : AttributeProgressionType, b : AttributeProgressionType = 0.0, c : AttributeProgressionType = 0.0) -> AttributeLevelSystem {
        guard a != 0 else {
            return AttributeLevelSystems.linearLevelSystem(step: b, offset: c)
        }
        
        return RPGAttributeLevelSystem(
            levelFunction: { progress in
                let invQuadratic = RPGMath.createInverseQuadratic(a: a, b: b, c: c)
                let floatingResult = invQuadratic(progress)
                return 1 + Int(floorf(floatingResult))
            },
            inverseLevelFunction: { level in
                let quadratic = RPGMath.createQuadratic(a: a, b: b, c: c)
                return quadratic(Float(level - 1))
            }
        )
    }
}
