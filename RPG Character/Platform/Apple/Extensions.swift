//
//  Extensions.swift
//  RPG Character
//
//  Created by Todd Greener on 7/15/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public extension RPGAttribute {
    init(attribute : AttributeModel) {
        self.init(
            progression: attribute.progression,
            baseline: attribute.baseline,
            levelSystem : attribute.levelSystem
        )
    }
    
    init(attribute : AttributeModel, progression : Float) {
        self.init(
            progression: progression,
            baseline: attribute.baseline,
            levelSystem : attribute.levelSystem
        )
    }
}

public extension RPGCharacter {
    init(character : CharacterModel) {
        self.init(attributes: character.attributes)
    }
}

public extension RPGCharacterUpdate {
    init(attributes : CharacterAttributes, function : @escaping AttributeUpdateFunction) {
        self.init(actions: attributes.map { keyValue in
            RPGCharacterUpdateAction(attribute: keyValue.key, action: function)
        })
    }
}

public extension RPGCharacterConstantUpdate {
    init(attributes : CharacterAttributes, function : @escaping AttributeConstantUpdateFunction) {
        self.init(actions: attributes.map { keyValue in
            RPGCharacterConstantUpdateAction(attribute: keyValue.key, action: function)
        })
    }
}
