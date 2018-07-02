//
//  CharacterUpdate.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public protocol CharacterUpdateAction {
    var attribute : AttributeName { get }
    var action : AttributeUpdateFunction { get }
}

public struct RPGCharacterUpdateAction : CharacterUpdateAction {
    public let attribute : AttributeName
    public let action : AttributeUpdateFunction
}

public protocol CharacterUpdate {
    var actions : [AttributeName : CharacterUpdateAction] { get }
    static func linearDecayUpdate(attributes : CharacterAttributes, slope : AttributeProgressionType) -> CharacterUpdate
    static func quadraticDecayUpdate(attributes : CharacterAttributes, a : AttributeProgressionType, b : AttributeProgressionType) -> CharacterUpdate
}

public struct RPGCharacterUpdate : CharacterUpdate {
    public let actions : [AttributeName : CharacterUpdateAction]
    init(actions : [CharacterUpdateAction]) {
        var actionDict : [AttributeName : CharacterUpdateAction] = [:]
        actionDict.reserveCapacity(actions.count)
        self.actions = actions.reduce(actionDict) { accum, current in
            var result = accum
            result[current.attribute] = current
            return result
        }
    }
}


// Implement convenience operations for creating attribute decay functions.
public extension CharacterModel {
    public func linearDecayUpdate(slope : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate.linearDecayUpdate(attributes: self.attributes, slope: slope)
    }
    
    public func quadraticDecayUpdate(a : AttributeProgressionType, b : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate.quadraticDecayUpdate(attributes: self.attributes, a: a, b: b)
    }
    
    public func update(update: CharacterUpdate, step : Float) -> CharacterModel {
        return RPGCharacter(attributes: self.attributes.reduce([:]) { accum, keyValue in
            var result = accum
            let action = update.actions[keyValue.key]?.action
            result[keyValue.key] = action?(keyValue.value, step) ?? keyValue.value
            return result
        })
    }
}

public extension CharacterUpdate {
    public static func linearDecayUpdate(attributes : CharacterAttributes, slope : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate(actions: attributes.reduce([]) { accum, keyValue in
            var result = accum
            let action = AttributeUpdateFunctions.linearDecay(slope: slope)
            result.append(RPGCharacterUpdateAction(attribute: keyValue.key, action: action))
            return result
        })
    }
    
    public static func quadraticDecayUpdate(attributes : CharacterAttributes, a : AttributeProgressionType, b : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate(actions: attributes.reduce([]) { accum, keyValue in
            var result = accum
            let action = AttributeUpdateFunctions.quadraticDecay(a: a, b: b)
            result.append(RPGCharacterUpdateAction(attribute: keyValue.key, action: action))
            return result
        })
    }
}
