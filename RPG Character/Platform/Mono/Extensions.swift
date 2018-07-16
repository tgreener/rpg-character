//
//  Mono - Extensions.swift
//  RPG Character
//
//  Created by Todd Greener on 7/15/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

public extension RPGAttribute {
	/**
	 Copy Constructor. Create a new attribute with the values of a given attribute.
	 - Parameter attribute: The attribute to copy.
	 - Returns: An attribute copied from the given attribute.
	 */
	public convenience init(attribute : AttributeModel) {
		self.init(
		progression: attribute.progression,
		baseline: attribute.baseline,
		levelSystem : attribute.levelSystem
		)
	}

	/**
	 Progression update constructor. Create a new attribute that copies the given attribute,
	 but with an different progression value.
	 - Parameter attribute: The base attribute to copy.
	 - Parameter progression: The changed progression value to use.
	 - Returns: An attribute copied from the given attribute, but with the provided progression.
	 */
	public convenience init(attribute : AttributeModel, progression : Float) {
		self.init(
		progression: progression,
		baseline: attribute.baseline,
		levelSystem : attribute.levelSystem
		)
	}
}

public struct RPGCharacter : CharacterModel {
	convenience init(character : CharacterModel) {
		self.init(attributes: character.attributes)
	}
}

// stubby stubby