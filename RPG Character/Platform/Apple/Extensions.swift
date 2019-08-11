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
    init<Character: CharacterModel>(character : Character) where Character.AttributeName == AttributeName {
        self.init(attributes: character.attributes)
    }
}

public extension RPGCharacterUpdate {
    init(attributes : Action.ModelType.CharacterAttributes, function : @escaping AttributeUpdateFunction) {
        self.init(actions: attributes.map { keyValue in
            Action(attribute: keyValue.key, action: function)
        })
    }
}

public extension RPGCharacterConstantUpdate {
    init(attributes : Action.ModelType.CharacterAttributes, function : @escaping AttributeConstantUpdateFunction) {
        self.init(actions: attributes.map { keyValue in
            Action(attribute: keyValue.key, action: function)
        })
    }
}
