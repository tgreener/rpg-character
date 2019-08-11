//
//  Character.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

//import Foundation

/// Defines an RPG character. This is primarily a dictionary of attribute names to attributes.
public protocol CharacterModel {
    associatedtype AttributeName: Hashable
    associatedtype Update: CharacterUpdate where AttributeName == Update.ModelType.AttributeName
    typealias CharacterAttributes = [AttributeName : AttributeValue]
    
    /// The character's attributes. A dictionary of attribute names -> attribute values.
    var attributes : CharacterAttributes { get }

    /// Convenience subscript operator for accessing character attributes.
    subscript(key : AttributeName) -> AttributeValue? { get set }

    /**
     Run the update over the character attributes, and get an updated character model.
     The update will change any attributes with names that match names in the update,
     but all other will remain unchanged.
     - Parameter update: The update that will be performed (see CharacterUpdate).
     - Parameter step: The magnitude of the update.
     - Returns: A new character model with the updated attribute values.
     */
    func update<Update : CharacterUpdate>(update: Update, step : Float) -> Self where Update.ModelType == Self
    
    /**
     Run the update over the character attributes, and get an updated character model.
     The update will change any attributes with names that match names in the update,
     but all other will remain unchanged. The update step is prebaked into each update
     action in the update.
     - Parameter update: The update that will be performed (see CharacterUpdate).
     - Returns: A new character model with the updated attribute values.
     */
    func update<Update : CharacterConstantUpdate>(update: Update) -> Self where Update.ModelType == Self
    
    /**
     A convenience method for creating a linear decay update that will effect all of a
     characters attributes.
     - Parameter slope: The slope of the linear decay function
     - Returns: A character update that applies linear decay to all of the character's attributes.
     */
    func linearDecayUpdate(slope : AttributeProgressionType) -> Update
    
    /**
     A convenience method for creating a linear decay update that will effect all of a
     characters attributes.
     - Parameter a: The coefficient of power 2 part of the quadratic function.
     - Parameter b: The coefficient of power 1 part of the quadratic function.
     - Returns: A character update that applies quadratic decay to all of the character's attributes.
     */
    func quadraticDecayUpdate(a : AttributeProgressionType, b : AttributeProgressionType) -> Update

    /**
     Copy initializer, creates a new character model that copies another character model's attributes.
     - Parameter character: The character to copy.
     - Returns: A new character model with copies of another's attributes.
     */
    init<Character: CharacterModel>(character : Character) where Character.AttributeName == Self.AttributeName
}

/// Concrete implementation of CharacterModel
public struct RPGCharacter<AttributeName: Hashable> : CharacterModel {
    public typealias Update = RPGCharacterUpdate<RPGCharacterUpdateAction<Self>>
    
    public var attributes: [AttributeName : AttributeValue]

    /**
     Initialize a new character model with the given set of attributes.
     - Parameter attributes: The character's attributes.
     - Returns: A new character model.
     */
    public init(attributes : CharacterAttributes = [:]) {
        self.attributes = attributes
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
