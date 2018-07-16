//
//  SwiftMath.swift
//  RPG Character
//
//  Created by Todd Greener on 7/15/18.
//  Copyright © 2018 Todd Greener. All rights reserved.
//

func max<T>(_ a : T, _ b :T) -> T where T : IComparable {
	return a.CompareTo(b) >= 0 ? a : b
}

func min<T>(_ a : T, _ b :T) -> T where T : IComparable {
	return a.CompareTo(b) < 0 ? a : b
}