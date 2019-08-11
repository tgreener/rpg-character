//
//  CharacterUpdate.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

/// Defines the action taken to update a character's single attribute.
public protocol CharacterUpdateAction {
    associatedtype ModelType : CharacterModel
    /// The name of the attribute that will be effected by this update.
    var attribute : ModelType.AttributeName { get }

    /// The function that will be applied to this attribute as the udpate.
    var action : AttributeUpdateFunction { get }
    
    init(attribute: ModelType.AttributeName, action: @escaping AttributeUpdateFunction)
}

/// Concrete type of CharacterUpdateAction
public struct RPGCharacterUpdateAction<ModelType : CharacterModel> : CharacterUpdateAction {
    public let attribute : ModelType.AttributeName
    public let action : AttributeUpdateFunction
    
    public init(attribute: ModelType.AttributeName, action: @escaping AttributeUpdateFunction) {
        self.attribute = attribute
        self.action = action
    }
}

// Defines the action taken to update a character's single attribute, where the update function has a constant step.
public protocol CharacterConstantUpdateAction {
    associatedtype ModelType : CharacterModel
    /// The name of the attribute that will be effected by this update.
    var attribute : ModelType.AttributeName { get }
    
    /// The function that will be applied to this attribute as the udpate.
    var action : AttributeConstantUpdateFunction { get }
    
    init(attribute: ModelType.AttributeName, action: @escaping AttributeConstantUpdateFunction)
}

/// Concrete type of CharacterUpdateAction
public struct RPGCharacterConstantUpdateAction<ModelType : CharacterModel> : CharacterConstantUpdateAction {
    public let attribute : ModelType.AttributeName
    public let action : AttributeConstantUpdateFunction
    
    public init(attribute: ModelType.AttributeName, action: @escaping AttributeConstantUpdateFunction) {
            self.attribute = attribute
            self.action = action
        }
}

/// A type with a collection of attribute update actions for a character.
/// Also has static convenience functions for creating updates.
/// See CharacterModel.update for usage information.
public protocol CharacterUpdate {
    associatedtype Action : CharacterUpdateAction
    typealias ModelType = Action.ModelType
    /// The actions for updating the attributes.
    var actions : [ModelType.AttributeName : Action] { get }

    /**
     Create a CharacterUpdate from a collection of character attributes and a function.
     - Parameter attributes: The attributes effected by this update.
     - Parameter function: The function to apply to the attributes.
     - Returns: A new character update.
     */
    init(attributes : ModelType.CharacterAttributes, function : @escaping AttributeUpdateFunction)

    /**
     A convenience method for creating a linear decay update that will effect the given attributes.
     - Parameter attributes: The attributes effected by this update.
     - Parameter slope: The slope of the linear decay function
     - Returns: A character update that applies linear decay to the given attributes.
     */
    static func linearDecayUpdate(attributes : ModelType.CharacterAttributes, slope : AttributeProgressionType) -> Self

    /**
     A convenience method for creating a linear decay update that will effect the given attributes.
     - Parameter attributes: The attributes effected by this update.
     - Parameter a: The coefficient of power 2 part of the quadratic function.
     - Parameter b: The coefficient of power 1 part of the quadratic function.
     - Returns: A character update that applies quadratic decay to the given attributes.
     */
    static func quadraticDecayUpdate(attributes : ModelType.CharacterAttributes, a : AttributeProgressionType, b : AttributeProgressionType) -> Self
}

/// Concrete implementation of CharacterUpdate
public struct RPGCharacterUpdate<Action : CharacterUpdateAction> : CharacterUpdate {
    public let actions : [Action.ModelType.AttributeName : Action]

    /**
     Create a CharacterUpdate from an array of CharacterUpdateActions.
     - Parameter actions: The actions that define this update.
     - Returns: A new character update.
     */
    public init(actions : [Action]) {
        var actionDict : [ModelType.AttributeName : Action] = [:]

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
    associatedtype Action: CharacterConstantUpdateAction
    typealias ModelType = Action.ModelType
    
    /// The actions for updating the attributes.
    var actions : [ModelType.AttributeName : Action] { get }
    
    /**
     Create a CharacterUpdate from a collection of character attributes and a function.
     - Parameter attributes: The attributes effected by this update.
     - Parameter function: The function to apply to the attributes.
     - Returns: A new character update.
     */
    init(attributes : ModelType.CharacterAttributes, function : @escaping AttributeConstantUpdateFunction)
}

/// Concrete implementation of CharacterConstantUpdate
public struct RPGCharacterConstantUpdate<Action: CharacterConstantUpdateAction> : CharacterConstantUpdate {
    public let actions : [Action.ModelType.AttributeName : Action]
    
    /**
     Create a CharacterUpdate from an array of CharacterUpdateActions.
     - Parameter actions: The actions that define this update.
     - Returns: A new character update.
     */
    public init(actions : [Action]) {
        var actionDict : [ModelType.AttributeName : Action] = [:]
        
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
    func update<Update : CharacterUpdate>(update: Update, step : Float) -> Self where Update.ModelType == RPGCharacter<AttributeName> {
        return RPGCharacter<AttributeName>(attributes: self.attributes.reduce([AttributeName : AttributeValue]()) { accum, keyValue in
            var result = accum
            let action = update.actions[keyValue.key]?.action
            result[keyValue.key] = action?(keyValue.value, step) ?? keyValue.value
            return result
        })
    }
    
    func update<Update : CharacterConstantUpdate>(update: Update) -> Self where Update.ModelType == RPGCharacter<AttributeName> {
        return RPGCharacter<AttributeName>(attributes: self.attributes.reduce([AttributeName : AttributeValue]()) { accum, keyValue in
            var result = accum
            let action = update.actions[keyValue.key]?.action
            result[keyValue.key] = action?(keyValue.value) ?? keyValue.value
            return result
        })
    }

    // Implement convenience operations for creating attribute decay functions.

    func linearDecayUpdate(slope: AttributeProgressionType) -> Update {
        return Update.linearDecayUpdate(attributes: self.attributes, slope: slope)
    }

    func quadraticDecayUpdate(a: AttributeProgressionType, b: AttributeProgressionType) -> Update {
        return Update.quadraticDecayUpdate(attributes: self.attributes, a: a, b: b)
    }
}

public extension RPGCharacterUpdate {
    static func linearDecayUpdate(attributes : Action.ModelType.CharacterAttributes, slope : AttributeProgressionType) -> Self {
        return RPGCharacterUpdate<Action>(
            attributes: attributes,
            function: AttributeUpdateFunctions.linearDecay(slope: slope)
        )
    }

    static func quadraticDecayUpdate(attributes : Action.ModelType.CharacterAttributes, a : AttributeProgressionType, b : AttributeProgressionType) -> Self {
        return RPGCharacterUpdate<Action>(
            attributes: attributes,
            function: AttributeUpdateFunctions.quadraticDecay(a: a, b: b)
        )
    }
}
