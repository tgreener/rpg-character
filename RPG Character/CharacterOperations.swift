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

public protocol CharacterUpdateEvent {
    var actions : [AttributeName : CharacterUpdateAction] { get }
}

public struct RPGCharacterUpdateEvent : CharacterUpdateEvent {
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

public func onUpdateEvent(character: CharacterModel, event: CharacterUpdateEvent, step : Float) -> CharacterModel {
    return RPGCharacter(attributes: character.attributes.reduce([:]) { accum, keyValue in
        var result = accum
        let action = event.actions[keyValue.key]?.action
        result[keyValue.key] = action?(keyValue.value, step) ?? keyValue.value
        return result
    })
}
