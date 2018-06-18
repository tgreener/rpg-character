//
//  CharacterFunctions.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

func onUpdateEvent(character: CharacterModel, event: CharacterUpdateEvent) -> CharacterModel {
    return RPGCharacter(attributes: character.attributes.reduce([:]) { accum, keyValue in
        var result = accum
        let action = event.actions[keyValue.key]?.action
        result[keyValue.key] = action?(keyValue.value) ?? keyValue.value
        return result
    })
}

