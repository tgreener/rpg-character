//
//  Attribute.swift
//  RPG Character
//
//  Created by Todd Greener on 6/28/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

/// The attribute's value type.
public typealias AttributeValue = AttributeModel

/// The type used to calculate attribute progression.
public typealias AttributeProgressionType = Float

/// The type used to represent attribute level.
public typealias AttributeLevelType = Int

/// Alias for a function that maps from attribute progression to attribute level.
public typealias AttributeLevelFunction = (AttributeProgressionType) -> AttributeLevelType

/// Alias for a function that maps from attribute level to attribute progression.
public typealias AttributeInverseLevelFunction = (AttributeLevelType) -> AttributeProgressionType

/// A value that has functions for mapping between progression and levels (and vice versa).
public protocol AttributeLevelSystem {
    /// A function that maps from attribute progression to attribute level.
    var levelFunction : AttributeLevelFunction { get }
    /// A function that maps from attribute level to attribute progression.
    var inverseLevelFunction : AttributeInverseLevelFunction { get }
}

/// A concrete type of AttributeLevelSystem
public struct RPGAttributeLevelSystem : AttributeLevelSystem {
    public let levelFunction : AttributeLevelFunction
    public let inverseLevelFunction : AttributeInverseLevelFunction
}

/// A value that describes an attribute.
public protocol AttributeModel {
    /// The default value for the attribute. Decay updates move progression toward this value.
    var baseline : Float { get }

    /// The current value of the attribute. Used in the attribute update system to calculate updated attributes.
    var progression : Float { get }

    /// The level system used to map between progression and attribute levels.
    var levelSystem : AttributeLevelSystem { get }

    /// The current level of the attribute.
    var currentLevel : AttributeLevelType { get }

    /**
     The progression value for a given level of this attribute.
     - Parameter level: The level to map to progression.
     - Returns: The progression value that relates to the given level.
     */
    func progressionAtLevel(level : AttributeLevelType) -> AttributeProgressionType
    
    /**
     Copy Constructor. Create a new attribute with the values of a given attribute.
     - Parameter attribute: The attribute to copy.
     - Returns: An attribute copied from the given attribute.
     */
    init(attribute : AttributeModel)
    
    /**
     Progression update constructor. Create a new attribute that copies the given attribute,
     but with an different progression value.
     - Parameter attribute: The base attribute to copy.
     - Parameter progression: The changed progression value to use.
     - Returns: An attribute copied from the given attribute, but with the provided progression.
     */
    init(attribute : AttributeModel, progression : Float)
}

/// A concrete type of AttributeModel.
public struct RPGAttribute : AttributeModel {
    public let progression : AttributeProgressionType
    public let baseline : AttributeProgressionType
    public let levelSystem : AttributeLevelSystem

    public var currentLevel: AttributeLevelType {
        return self.levelSystem.levelFunction(self.progression)
    }

    public func progressionAtLevel(level: AttributeLevelType) -> AttributeProgressionType {
        return self.levelSystem.inverseLevelFunction(level)
    }

    /**
     Primary constructor. Creates an attribute given all necessary information.
     - Parameter progression: The initial progression of the attribute.
     - Parameter baseline: The default progression that this attribute decays toward.
     - Parameter levelSystem: A level system for mapping between progression and level.
     - Returns: An attribute created with the given values.
     */
    public init(
        progression : AttributeProgressionType,
        baseline : AttributeProgressionType,
        levelSystem : AttributeLevelSystem
        ) {
        self.baseline = max(0.0, baseline)
        self.progression = progression
        self.levelSystem = levelSystem
    }
}
