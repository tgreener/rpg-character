//
//  Character.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public typealias CharacterAttributeName = String
public typealias CharacterAttributeValue = CharacterAttributeModel
public typealias CharacterAttributes = [CharacterAttributeName : CharacterAttributeValue]

public protocol CharacterAttributeModel {
    var currentValue : Float { get }
    var progression : Float { get }
}

public struct RPGCharacterAttribute : CharacterAttributeModel {
    public let currentValue : Float
    public let progression : Float
}

public protocol CharacterModel {
    var attributes : CharacterAttributes { get }
    subscript(key : CharacterAttributeName) -> CharacterAttributeValue? { get set }
}

public struct RPGCharacter : CharacterModel {
    public var attributes: CharacterAttributes
    
    init(attributes : CharacterAttributes = [:]) {
        self.attributes = attributes
    }
    
    init(character : CharacterModel) {
        self.init(attributes: character.attributes)
    }
    
    public subscript(key : CharacterAttributeName) -> CharacterAttributeValue? {
        get {
            return self.attributes[key]
        }
        set(val) {
            guard let v = val else { return }
            
            self.attributes[key] = v
        }
    }
}
