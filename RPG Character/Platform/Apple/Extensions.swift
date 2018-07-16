//
//  Extensions.swift
//  RPG Character
//
//  Created by Todd Greener on 7/15/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import Foundation

public extension RPGAttribute {
    public init(attribute : AttributeModel) {
        self.init(
            progression: attribute.progression,
            baseline: attribute.baseline,
            levelSystem : attribute.levelSystem
        )
    }
    
    public init(attribute : AttributeModel, progression : Float) {
        self.init(
            progression: progression,
            baseline: attribute.baseline,
            levelSystem : attribute.levelSystem
        )
    }
}
