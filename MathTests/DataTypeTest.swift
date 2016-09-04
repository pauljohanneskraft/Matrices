//
//  DataTypeTest.swift
//  Math
//
//  Created by Paul Kraft on 01.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation
import XCTest

protocol TypeTest {
	associatedtype DataType
	
	var elements : [DataType] { get }
	
}
extension TypeTest {
	
	func forAll<T>(_ char: String, assert cond: (DataType, T) -> Bool = { _,_ in return true }, _ f: (DataType) -> T) {
		let n = self.elements
		// var avgtime = 0.0
		for r in n {
			let start = NSDate().timeIntervalSinceReferenceDate
			let fr = f(r)
			let end = NSDate().timeIntervalSinceReferenceDate
			let time = end-start
			// print("\(char)(\(r))", "=", fr, "in", time)
			assert(time >= 0.0, time.description)
			// avgtime += time
			XCTAssert(cond(r, fr), "\(char)(\(r)) != \(fr)")
		}
		// print("avg time:", avgtime / Double(n.count), "total:", avgtime)
	}
	
	func forAll<T>(_ char: String, assert cond: (DataType, DataType, T) -> Bool = { _,_,_ in return true }, _ f: (DataType, DataType) -> T) {
		let n = self.elements
		// var avgtime = 0.0
		for r in n {
			for q in n {
				let start = NSDate().timeIntervalSinceReferenceDate
				let frq = f(r, q)
				let end = NSDate().timeIntervalSinceReferenceDate
				let time = end-start
				// print(r, char, q, "=", frq, "in", time)
				XCTAssert(time >= 0, "\(time)")
				// avgtime += time
				let t = cond(r,q, frq)
				if !t { print(".", terminator: "") }
				XCTAssert(t, "\(r) \(char) \(q) == \(frq) doesn't meet the assertion criteria.")
			}
		}
		// print("avg time:", avgtime / Double(n.count * n.count), "total:", avgtime)
	}
}
