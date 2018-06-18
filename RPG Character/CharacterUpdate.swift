//
//  CharacterUpdate.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

typealias CharacterAttributeUpdateFunction = (CharacterAttributeValue) -> CharacterAttributeValue

protocol CharacterUpdateAction {
    var attribute : CharacterAttributeName { get }
    var action : CharacterAttributeUpdateFunction { get }
}

struct RPGCharacterUpdateAction : CharacterUpdateAction {
    let attribute : CharacterAttributeName
    let action : CharacterAttributeUpdateFunction
}

protocol CharacterUpdateEvent {
    var actions : [CharacterAttributeName : CharacterUpdateAction] { get }
}

struct RPGCharacterUpdateEvent : CharacterUpdateEvent {
    let actions : [CharacterAttributeName : CharacterUpdateAction]
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
