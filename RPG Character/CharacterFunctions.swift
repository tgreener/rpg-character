//
//  CharacterFunctions.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public typealias CharacterAttributeUpdateFunction = (CharacterAttributeValue) -> CharacterAttributeValue
public typealias CharacterAttributeDecayFunction = (Float) -> CharacterAttributeUpdateFunction

public func onUpdateEvent(character: CharacterModel, event: CharacterUpdateEvent) -> CharacterModel {
    return RPGCharacter(attributes: character.attributes.reduce([:]) { accum, keyValue in
        var result = accum
        let action = event.actions[keyValue.key]?.action
        result[keyValue.key] = action?(keyValue.value) ?? keyValue.value
        return result
    })
}

public struct CharacterAttributeDecayFunctions {
    public static func linearDecay(multiplier : Float, offset : Float) -> CharacterAttributeDecayFunction {
        return { (dt : Float) in { attribute in
            let direction : Float = attribute.progression >= attribute.baseline ? -1 : 1
            let progression = attribute.progression + (((multiplier * dt) + offset) * direction)
            
            return RPGCharacterAttribute (character: attribute, progression: progression)
        }}
    }
}

extension CharacterAttributeDecayFunctions {
    static func clampUpdatedValueToBaseline(current : Float, updated : Float, baseline : Float) -> Float {
        let allowedRange = current > updated ? (baseline...Float.infinity) : (-Float.infinity...baseline)
        return allowedRange.clamp(updated)
    }
}

public struct CharacterAttributeLevelSystems {
    // Create a level system that always returns zero. Used as an error case.
    public static func zeroed() -> RPGCharacterAttributeLevelSystem {
        return RPGCharacterAttributeLevelSystem(
            levelFunction: { _ in 0 },
            inverseLevelFunction: { _ in 0 }
        )
    }
    
    public static func linearLevelSystem(step : Float) -> CharacterAttributeLevelSystem {
        return RPGCharacterAttributeLevelSystem(
            levelFunction: { progress in Int(floorf(progress / step)) + 1 },
            inverseLevelFunction: { level in Float(level - 1) * step }
        )
    }
    
    public static func quadraticLevelSystem(a : Float, b : Float = 0.0, c : Float = 0.0) -> CharacterAttributeLevelSystem {
        guard a != 0 else {
            return CharacterAttributeLevelSystems.zeroed()
        }
        return RPGCharacterAttributeLevelSystem(
            levelFunction: { progress in
                let sqrtPart = sqrtf(powf(b, 2.0) - 4 * a * (c - progress))
                return 1 + Int(floorf((-b + sqrtPart) / (2*a)))
            },
            inverseLevelFunction: { level in
                let aPart = (a * powf(Float(level - 1), 2.0))
                let bPart = (b * Float(level - 1))
                return aPart + bPart + c
            }
        )
    }
}
