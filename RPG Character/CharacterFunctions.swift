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

public struct CharacterDecayFunctions {
    public static func linearDecay(multiplier : Float, offset : Float) -> CharacterAttributeDecayFunction {
        return { (dt : Float) in { attribute in
            let direction : Float = attribute.progression >= attribute.baseline ? -1 : 1
            
            var descriptor = RPGCharacterAttributeDescriptor()
            descriptor.baseline = attribute.baseline
            descriptor.levelFunction = attribute.levelFunction
            descriptor.inverseLevelFunction = attribute.inverseLevelFunction
            
            descriptor.progression = attribute.progression + (((multiplier * dt) + offset) * direction)
            
            return RPGCharacterAttribute(descriptor: descriptor)!
        }}
    }
}

extension CharacterDecayFunctions {
    static func clampUpdatedValueToBaseline(current : Float, updated : Float, baseline : Float) -> Float {
        let allowedRange = current > updated ? (baseline...Float.infinity) : (-Float.infinity...baseline)
        return allowedRange.clamp(updated)
    }
}
