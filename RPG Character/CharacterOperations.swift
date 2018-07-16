//
//  CharacterUpdate.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

/// Defines the action taken to update a character's single attribute.
public protocol CharacterUpdateAction {
    /// The name of the attribute that will be effected by this update.
    var attribute : AttributeName { get }

    /// The function that will be applied to this attribute as the udpate.
    var action : AttributeUpdateFunction { get }
}

/// Concrete type of CharacterUpdateAction
public struct RPGCharacterUpdateAction : CharacterUpdateAction {
    public let attribute : AttributeName
    public let action : AttributeUpdateFunction
}

/// A type with a collection of attribute update actions for a character.
/// Also has static convenience functions for creating updates.
/// See CharacterModel.update for usage information.
public protocol CharacterUpdate {

    /// The actions for updating the attributes.
    var actions : [AttributeName : CharacterUpdateAction] { get }

    /**
     A convenience method for creating a linear decay update that will effect the given attributes.
     - Parameter attributes: The attributes effected by this update.
     - Parameter slope: The slope of the linear decay function
     - Returns: A character update that applies linear decay to the given attributes.
     */
    static func linearDecayUpdate(attributes : CharacterAttributes, slope : AttributeProgressionType) -> CharacterUpdate

    /**
     A convenience method for creating a linear decay update that will effect the given attributes.
     - Parameter attributes: The attributes effected by this update.
     - Parameter a: The coefficient of power 2 part of the quadratic function.
     - Parameter b: The coefficient of power 1 part of the quadratic function.
     - Returns: A character update that applies quadratic decay to the given attributes.
     */
    static func quadraticDecayUpdate(attributes : CharacterAttributes, a : AttributeProgressionType, b : AttributeProgressionType) -> CharacterUpdate
}

/// Concrete implementation of CharacterUpdate
public struct RPGCharacterUpdate : CharacterUpdate {
    public let actions : [AttributeName : CharacterUpdateAction]

    /**
     Create a CharacterUpdate from an array of CharacterUpdateActions.
     - Parameter actions: The actions that define this update.
     - Returns: A new character update.
     */
    init(actions : [CharacterUpdateAction]) {
        var actionDict : [AttributeName : CharacterUpdateAction] = [:]
        actionDict.reserveCapacity(actions.count)
        self.actions = actions.reduce(actionDict) { accum, current in
            var result = accum
            result[current.attribute] = current
            return result
        }
    }

    /**
     Create a CharacterUpdate from a collection of character attributes and a function.
     - Parameter attributes: The attributes effected by this update.
     - Parameter function: The function to apply to the attributes.
     - Returns: A new character update.
     */
    init(attributes : CharacterAttributes, function : @escaping AttributeUpdateFunction) {
        self.init(actions: attributes.map { keyValue in
            RPGCharacterUpdateAction(attribute: keyValue.key, action: function)
        })
    }
}

public extension CharacterModel {
    /**
     Run the update over the character attributes, and get an updated character model.
     The update will change any attributes with names that match names in the update,
     but all other will remain unchanged.
     - Parameter update: The update that will be performed (see CharacterUpdate).
     - Parameter step: The magnitude of the update.
     - Returns: A new character model with the updated attribute values.
     */
    public func update(update: CharacterUpdate, step : Float) -> CharacterModel {
        return RPGCharacter(attributes: self.attributes.reduce([:]) { accum, keyValue in
            var result = accum
            let action = update.actions[keyValue.key]?.action
            result[keyValue.key] = action?(keyValue.value, step) ?? keyValue.value
            return result
        })
    }

    // Implement convenience operations for creating attribute decay functions.
    /**
     A convenience method for creating a linear decay update that will effect all of a
     characters attributes.
     - Parameter slope: The slope of the linear decay function
     - Returns: A character update that applies linear decay to all of the character's attributes.
     */
    public func linearDecayUpdate(slope : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate.linearDecayUpdate(attributes: self.attributes, slope: slope)
    }

    /**
     A convenience method for creating a linear decay update that will effect all of a
     characters attributes.
     - Parameter a: The coefficient of power 2 part of the quadratic function.
     - Parameter b: The coefficient of power 1 part of the quadratic function.
     - Returns: A character update that applies quadratic decay to all of the character's attributes.
     */
    public func quadraticDecayUpdate(a : AttributeProgressionType, b : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate.quadraticDecayUpdate(attributes: self.attributes, a: a, b: b)
    }
}

public extension RPGCharacterUpdate {
    public static func linearDecayUpdate(attributes : CharacterAttributes, slope : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate(
            attributes: attributes,
            function: AttributeUpdateFunctions.linearDecay(slope: slope)
        )
    }

    public static func quadraticDecayUpdate(attributes : CharacterAttributes, a : AttributeProgressionType, b : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate(
            attributes: attributes,
            function: AttributeUpdateFunctions.quadraticDecay(a: a, b: b)
        )
    }
}
