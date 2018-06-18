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

public protocol CharacterAttributeModel {
    var baseline : Float { get }
    var progression : Float { get }
    var levelFunction : CharacterAttributeLevelFunction { get }
    var inverseLevelFunction : CharacterAttributeInverseLevelFunction { get }
}

public struct RPGCharacterAttributeDescriptor {
    public var progression : Float? = nil
    public var baseline : Float? = nil
    public var levelFunction : CharacterAttributeLevelFunction? = nil
    public var inverseLevelFunction: CharacterAttributeInverseLevelFunction? = nil
    
    public var isValid : Bool {
        return self.progression != nil &&
            self.baseline != nil &&
            self.levelFunction != nil &&
            self.inverseLevelFunction != nil
    }
    
}

public struct RPGCharacterAttribute : CharacterAttributeModel {
    public let progression : Float
    public let baseline : Float
    public let levelFunction : CharacterAttributeLevelFunction
    public let inverseLevelFunction: CharacterAttributeInverseLevelFunction
    
    init(
        progression : Float,
        baseline : Float,
        levelFunction : @escaping CharacterAttributeLevelFunction,
        inverseLevelFunction : @escaping CharacterAttributeInverseLevelFunction
    ) {
        self.baseline = (0.0...Float.infinity).clamp(baseline)
        self.progression = (0.0...1.0).clamp(progression)
        self.levelFunction = levelFunction
        self.inverseLevelFunction = inverseLevelFunction
    }
    
    init?(descriptor : RPGCharacterAttributeDescriptor) {
        guard let progression = descriptor.progression,
            let baseline = descriptor.baseline,
            let levelFunction = descriptor.levelFunction,
            let inverseLevelFunction = descriptor.inverseLevelFunction
            else { return nil }
        
        self.init(
            progression: progression,
            baseline: baseline,
            levelFunction : levelFunction,
            inverseLevelFunction: inverseLevelFunction
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
