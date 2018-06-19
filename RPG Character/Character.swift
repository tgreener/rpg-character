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
public typealias CharacterAttributeLevelFunction = (Float) -> Int
public typealias CharacterAttributeInverseLevelFunction = (Int) -> Float

public protocol CharacterAttributeLevelSystem {
    var levelFunction : CharacterAttributeLevelFunction { get }
    var inverseLevelFunction : CharacterAttributeInverseLevelFunction { get }
}

public struct RPGCharacterAttributeLevelSystem : CharacterAttributeLevelSystem {
    public let levelFunction : CharacterAttributeLevelFunction
    public let inverseLevelFunction : CharacterAttributeInverseLevelFunction
}

public protocol CharacterAttributeModel {
    var baseline : Float { get }
    var progression : Float { get }
    var levelSystem : CharacterAttributeLevelSystem { get }
}

public struct RPGCharacterAttribute : CharacterAttributeModel {
    public let progression : Float
    public let baseline : Float
    public let levelSystem : CharacterAttributeLevelSystem
    
    init(
        progression : Float,
        baseline : Float,
        levelSystem : CharacterAttributeLevelSystem
    ) {
        self.baseline = (0.0...Float.infinity).clamp(baseline)
        self.progression = progression
        self.levelSystem = levelSystem
    }
    
    init(attribute : CharacterAttributeModel) {
        self.init(
            progression: attribute.progression,
            baseline: attribute.baseline,
            levelSystem : attribute.levelSystem
        )
    }
    
    init(character : CharacterAttributeModel, progression : Float) {
        self.init(
            progression: progression,
            baseline: character.baseline,
            levelSystem : character.levelSystem
        )
    }
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
