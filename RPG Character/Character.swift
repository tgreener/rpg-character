//
//  Character.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public typealias AttributeName = String
public typealias CharacterAttributes = [AttributeName : AttributeValue]

/// Defines an RPG character. This is primarily a dictionary of attribute names to attributes.
public protocol CharacterModel {
    /// The character's attributes. A dictionary of attribute names -> attribute values.
    var attributes : CharacterAttributes { get }
    
    /// Convenience subscript operator for accessing character attributes.
    subscript(key : AttributeName) -> AttributeValue? { get set }
}

/// Concrete implementation of CharacterModel
public struct RPGCharacter : CharacterModel {
    public var attributes: CharacterAttributes
    
    /**
     Initialize a new character model with the given set of attributes.
     - Parameter attributes: The character's attributes.
     - Returns: A new character model.
     */
    init(attributes : CharacterAttributes = [:]) {
        self.attributes = attributes
    }
    
    /**
     Copy initializer, creates a new character model that copies another character model's attributes.
     - Parameter character: The character to copy.
     - Returns: A new character model with copies of another's attributes.
     */
    init(character : CharacterModel) {
        self.init(attributes: character.attributes)
    }
    
    public subscript(key : AttributeName) -> AttributeValue? {
        get {
            return self.attributes[key]
        }
        set(val) {
            guard let v = val else { return }
            
            self.attributes[key] = v
        }
    }
}
