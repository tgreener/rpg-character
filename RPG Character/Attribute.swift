//
//  Attribute.swift
//  RPG Character
//
//  Created by Todd Greener on 6/28/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public typealias AttributeName = String
public typealias AttributeValue = AttributeModel
public typealias AttributeProgressionType = Float
public typealias AttributeLevelType = Int
public typealias AttributeLevelFunction = (AttributeProgressionType) -> AttributeLevelType
public typealias AttributeInverseLevelFunction = (AttributeLevelType) -> AttributeProgressionType

public protocol AttributeLevelSystem {
    var levelFunction : AttributeLevelFunction { get }
    var inverseLevelFunction : AttributeInverseLevelFunction { get }
}

public struct RPGAttributeLevelSystem : AttributeLevelSystem {
    public let levelFunction : AttributeLevelFunction
    public let inverseLevelFunction : AttributeInverseLevelFunction
}

public protocol AttributeModel {
    var baseline : Float { get }
    var progression : Float { get }
    var levelSystem : AttributeLevelSystem { get }
}

public struct RPGAttribute : AttributeModel {
    public let progression : AttributeProgressionType
    public let baseline : AttributeProgressionType
    public let levelSystem : AttributeLevelSystem
    
    init(
        progression : AttributeProgressionType,
        baseline : AttributeProgressionType,
        levelSystem : AttributeLevelSystem
        ) {
        self.baseline = (0.0...Float.infinity).clamp(baseline)
        self.progression = progression
        self.levelSystem = levelSystem
    }
    
    init(attribute : AttributeModel) {
        self.init(
            progression: attribute.progression,
            baseline: attribute.baseline,
            levelSystem : attribute.levelSystem
        )
    }
    
    init(attribute : AttributeModel, progression : Float) {
        self.init(
            progression: progression,
            baseline: attribute.baseline,
            levelSystem : attribute.levelSystem
        )
    }
}
