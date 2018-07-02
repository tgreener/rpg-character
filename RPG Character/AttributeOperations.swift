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

fileprivate func clampUpdatedValueToBaseline(current : AttributeProgressionType, updated : AttributeProgressionType, baseline : AttributeProgressionType) -> AttributeProgressionType {
    let allowedRange = current > updated ? (baseline...Float.infinity) : (-Float.infinity...baseline)
    return allowedRange.clamp(updated)
}

public struct AttributeUpdateFunctions {
    // "Growth" can be in any direction
    public static func linearGrowth(coefficient : Float, offset : Float) -> AttributeUpdateFunction {
        return { attribute, step in
            return AttributeUpdateFunctions.linearGrowthCalculation(
                attribute: attribute,
                step: step,
                coefficient: coefficient,
                offset: offset
            )
        }
    }
    
    public static func constantLinearGrowth(step: Float, coefficient : Float, offset : Float) -> AttributeConstantUpdateFunction {
        return { attribute in
            return AttributeUpdateFunctions.linearGrowthCalculation(
                attribute: attribute,
                step: step,
                coefficient: coefficient,
                offset: offset
            )
        }
    }
    
    private static func linearGrowthCalculation(
        attribute: AttributeValue,
        step: Float,
        coefficient : Float,
        offset : Float) -> AttributeValue
    {
        let progression = attribute.progression + ((coefficient * step) + offset)
        return RPGAttribute (attribute: attribute, progression: progression)
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
        return { attribute, dt in
            let direction : Float = attribute.progression >= attribute.baseline ? -1 : 1
            
            let timeToProgress = RPGMath.createQuadratic(a: a, b: b)
            let progressToTime = RPGMath.createInverseQuadratic(a: a, b: b)
     
            let progressTime = progressToTime(attribute.progression)
            let updatedTime = progressTime + (dt * direction)
            let updatedProgress = timeToProgress(updatedTime)
            let result = clampUpdatedValueToBaseline(current: attribute.progression, updated: updatedProgress, baseline: attribute.baseline)
            
            return RPGAttribute(attribute: attribute, progression: result)
        }
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
