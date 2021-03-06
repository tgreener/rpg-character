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

// Defines the action taken to update a character's single attribute, where the update function has a constant step.
public protocol CharacterConstantUpdateAction {
    /// The name of the attribute that will be effected by this update.
    var attribute : AttributeName { get }
    
    /// The function that will be applied to this attribute as the udpate.
    var action : AttributeConstantUpdateFunction { get }
}

/// Concrete type of CharacterUpdateAction
public struct RPGCharacterConstantUpdateAction : CharacterConstantUpdateAction {
    public let attribute : AttributeName
    public let action : AttributeConstantUpdateFunction
}

/// A type with a collection of attribute update actions for a character.
/// Also has static convenience functions for creating updates.
/// See CharacterModel.update for usage information.
public protocol CharacterUpdate {

    /// The actions for updating the attributes.
    var actions : [AttributeName : CharacterUpdateAction] { get }

    /**
     Create a CharacterUpdate from a collection of character attributes and a function.
     - Parameter attributes: The attributes effected by this update.
     - Parameter function: The function to apply to the attributes.
     - Returns: A new character update.
     */
    init(attributes : CharacterAttributes, function : @escaping AttributeUpdateFunction)

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
    public init(actions : [CharacterUpdateAction]) {
        var actionDict : [AttributeName : CharacterUpdateAction] = [:]

        #if !ECHOES
        actionDict.reserveCapacity(actions.count)
        #endif

        self.actions = actions.reduce(actionDict) { accum, current in
            var result = accum
            result[current.attribute] = current
            return result
        }
    }
}

/// A type with a collection of attribute constant update actions for a character.
/// Also has static convenience functions for creating updates.
/// See CharacterModel.update for usage information.
public protocol CharacterConstantUpdate {
    
    /// The actions for updating the attributes.
    var actions : [AttributeName : CharacterConstantUpdateAction] { get }
    
    /**
     Create a CharacterUpdate from a collection of character attributes and a function.
     - Parameter attributes: The attributes effected by this update.
     - Parameter function: The function to apply to the attributes.
     - Returns: A new character update.
     */
    init(attributes : CharacterAttributes, function : @escaping AttributeConstantUpdateFunction)
}

/// Concrete implementation of CharacterConstantUpdate
public struct RPGCharacterConstantUpdate : CharacterConstantUpdate {
    public let actions : [AttributeName : CharacterConstantUpdateAction]
    
    /**
     Create a CharacterUpdate from an array of CharacterUpdateActions.
     - Parameter actions: The actions that define this update.
     - Returns: A new character update.
     */
    public init(actions : [CharacterConstantUpdateAction]) {
        var actionDict : [AttributeName : CharacterConstantUpdateAction] = [:]
        
        #if !ECHOES
        actionDict.reserveCapacity(actions.count)
        #endif
        
        self.actions = actions.reduce(actionDict) { accum, current in
            var result = accum
            result[current.attribute] = current
            return result
        }
    }
}

public extension RPGCharacter {
    func update(update: CharacterUpdate, step : Float) -> CharacterModel {
        return RPGCharacter(attributes: self.attributes.reduce([AttributeName : AttributeValue]()) { accum, keyValue in
            var result = accum
            let action = update.actions[keyValue.key]?.action
            result[keyValue.key] = action?(keyValue.value, step) ?? keyValue.value
            return result
        })
    }
    
    func update(update: CharacterConstantUpdate) -> CharacterModel {
        return RPGCharacter(attributes: self.attributes.reduce([AttributeName : AttributeValue]()) { accum, keyValue in
            var result = accum
            let action = update.actions[keyValue.key]?.action
            result[keyValue.key] = action?(keyValue.value) ?? keyValue.value
            return result
        })
    }

    // Implement convenience operations for creating attribute decay functions.

    func linearDecayUpdate(slope : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate.linearDecayUpdate(attributes: self.attributes, slope: slope)
    }

    func quadraticDecayUpdate(a : AttributeProgressionType, b : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate.quadraticDecayUpdate(attributes: self.attributes, a: a, b: b)
    }
}

public extension RPGCharacterUpdate {
    static func linearDecayUpdate(attributes : CharacterAttributes, slope : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate(
            attributes: attributes,
            function: AttributeUpdateFunctions.linearDecay(slope: slope)
        )
    }

    static func quadraticDecayUpdate(attributes : CharacterAttributes, a : AttributeProgressionType, b : AttributeProgressionType) -> CharacterUpdate {
        return RPGCharacterUpdate(
            attributes: attributes,
            function: AttributeUpdateFunctions.quadraticDecay(a: a, b: b)
        )
    }
}
