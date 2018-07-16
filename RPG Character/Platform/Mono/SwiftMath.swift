//
//  SwiftMath.swift
//  RPG Character
//
//  Created by Todd Greener on 7/15/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

import System

let M_E : Double = Math.E

func max<T>(_ a : T, _ b :T) -> T where T : IComparable {
	return a.CompareTo(b) >= 0 ? a : b
}

func min<T>(_ a : T, _ b :T) -> T where T : IComparable {
	return a.CompareTo(b) < 0 ? a : b
}

func pow(_ base : Float, _ power : Float) -> Float {
	return Math.Pow(base, power)
}

func pow(_ base : Double, _ power : Double) -> Double {
	return Math.Pow(base, power)
}

func log(_ x : Float) -> Float {
	return Math.Log(x)
}

func log(_ x : Double) -> Double {
	return Math.Log(x)
}