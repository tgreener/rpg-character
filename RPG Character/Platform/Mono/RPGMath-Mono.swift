//
//  RPGMath-Mono.swift
//  RPG Character
//
//  Created by Todd Greener on 7/15/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

public typealias AttributeCalculation<T> = (T) -> T

public extension RPGMath {
	/**
	 Create a calculation function of the form: `y = ax^2 + bx + c`
	 - Parameter a: Coefficient applied to the squared value and added to bx + c.
	 - Parameter b: Coefficient applied to the value and added to ax^2 + c.
	 - Parameter c: Constant value added to ax^2 + bx.
	 - Returns: A function that performs the quadratic calculation.
	 */
	public static func createQuadratic(a : Float, b : Float = 0.0, c : Float = 0.0) -> AttributeCalculation<Float> {
		return { x in (a * x * x) + (b * x) + c }
	}

	public static func createQuadratic(a : Double, b : Double = 0.0, c : Double = 0.0) -> AttributeCalculation<Double> {
		return { x in (a * x * x) + (b * x) + c }
	}

	/**
	 Create a calculation function in the form of the quadratic formula (inverse quadratic).
	 - Parameter a: All over 2a. See quadratic formula.
	 - Parameter b: Used in a couple different places in the quadratic formula.
	 - Parameter c: See quadratic formula.
	 - Returns: A function that performs the inverse quadratic calculation.
	 */
	public static func createInverseQuadratic(a : Float, b : Float = 0.0, c : Float = 0.0) -> AttributeCalculation<Float> {
		return { y in
			// Had to break this all up into sub expressions, because
			// the Swift type inference system was getting depressed
			// (and taking forever).
			let b2 : Float = b * b
			let ac4 : Float = 4 * a * (c - y)
			let sqrt_b2_4ac : Float = Math.Sqrt(b2 - ac4)
			let top : Float = -b + sqrt_b2_4ac
			return top / (2*a)
		}
	}

	public static func createInverseQuadratic(a : Double, b : Double = 0.0, c : Double = 0.0) -> AttributeCalculation<Double> {
		return { y in
			// Had to break this all up into sub expressions, because
			// the Swift type inference system was getting depressed
			// (and taking forever).
			let b2 : Double = b * b
			let ac4 : Double = 4 * a * (c - y)
			let sqrt_b2_4ac : Double = Math.Sqrt(b2 - ac4)
			let top : Double = -b + sqrt_b2_4ac
			return top / (2*a)
		}
	}

	public static let nan : Double = Double.NaN
}