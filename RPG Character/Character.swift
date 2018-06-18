//
//  Character.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

typealias CharacterAttributeName = String
typealias CharacterAttributeValue = CharacterAttributeModel
typealias CharacterAttributes = [CharacterAttributeName : CharacterAttributeValue]

protocol CharacterAttributeModel {
    var currentValue : Float { get }
    var progression : Float { get }
}

struct RPGCharacterAttribute : CharacterAttributeModel {
    let currentValue : Float
    let progression : Float
}

protocol CharacterModel {
    var attributes : CharacterAttributes { get }
    subscript(key : CharacterAttributeName) -> CharacterAttributeValue? { get set }
}

struct RPGCharacter : CharacterModel {
    var attributes: CharacterAttributes
    
    init(attributes : CharacterAttributes = [:]) {
        self.attributes = attributes
    }
    
    init(character : CharacterModel) {
        self.init(attributes: character.attributes)
    }
    
    subscript(key : CharacterAttributeName) -> CharacterAttributeValue? {
        get {
            return self.attributes[key]
        }
        set(val) {
            guard let v = val else { return }
            
            self.attributes[key] = v
        }
    }
}
