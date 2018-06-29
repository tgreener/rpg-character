//
//  Character.swift
//  RPG Character
//
//  Created by Todd Greener on 6/18/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public typealias CharacterAttributes = [AttributeName : AttributeValue]

public protocol CharacterModel {
    var attributes : CharacterAttributes { get }
    subscript(key : AttributeName) -> AttributeValue? { get set }
}

public struct RPGCharacter : CharacterModel {
    public var attributes: CharacterAttributes
    
    init(attributes : CharacterAttributes = [:]) {
        self.attributes = attributes
    }
    
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
