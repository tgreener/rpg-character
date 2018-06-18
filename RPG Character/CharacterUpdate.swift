//
//  CharacterUpdate.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public typealias CharacterAttributeUpdateFunction = (CharacterAttributeValue) -> CharacterAttributeValue

public protocol CharacterUpdateAction {
    var attribute : CharacterAttributeName { get }
    var action : CharacterAttributeUpdateFunction { get }
}

public struct RPGCharacterUpdateAction : CharacterUpdateAction {
    public let attribute : CharacterAttributeName
    public let action : CharacterAttributeUpdateFunction
}

public protocol CharacterUpdateEvent {
    var actions : [CharacterAttributeName : CharacterUpdateAction] { get }
}

public struct RPGCharacterUpdateEvent : CharacterUpdateEvent {
    public let actions : [CharacterAttributeName : CharacterUpdateAction]
    init(actions : [CharacterUpdateAction]) {
        var actionDict : [CharacterAttributeName : CharacterUpdateAction] = [:]
        actionDict.reserveCapacity(actions.count)
        self.actions = actions.reduce(actionDict) { accum, current in
            var result = accum
            result[current.attribute] = current
            return result
        }
    }
}
