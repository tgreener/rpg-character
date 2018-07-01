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
    static func linearDecayUpdate(attributes : CharacterAttributes, coefficient : AttributeProgressionType, offset : AttributeProgressionType) -> CharacterUpdate
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

public func onUpdateEvent(character: CharacterModel, update: CharacterUpdate, step : Float) -> CharacterModel {
    return RPGCharacter(attributes: character.attributes.reduce([:]) { accum, keyValue in
        var result = accum
        let action = update.actions[keyValue.key]?.action
        result[keyValue.key] = action?(keyValue.value, step) ?? keyValue.value
        return result
    })
}


// Implement convenience operations for creating attribute decay functions.
public extension CharacterModel {
    public func linearDecayUpdate(coefficient : AttributeProgressionType, offset : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate.linearDecayUpdate(attributes: self.attributes, coefficient: coefficient, offset: offset)
    }
}

public extension CharacterUpdate {
    public static func linearDecayUpdate(attributes : CharacterAttributes, coefficient : AttributeProgressionType, offset : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate(actions: attributes.reduce([]) { accum, keyValue in
            var result = accum
            let action = AttributeUpdateFunctions.linearDecay(coefficient: coefficient, offset: offset)
            result.append(RPGCharacterUpdateAction(attribute: keyValue.key, action: action))
            return result
        })
    }
}
