//
//  FractionTests.swift
//  Math
//
//  Created by Paul Kraft on 28.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import XCTest
import Math

class FractionTests: XCTestCase {
	// MID_PRIO
	
	func testReduced() {
		for _ in 0 ..< 100 {
			let num = (random() & 0xFFF).double
			let den = (random() & 0xFFF + 1).double
			let a = ConstantFunction(num) / ConstantFunction(den)
			XCTAssert(a is ConstantFunction)
			if let c = a as? ConstantFunction {
				let rat = num / den
				XCTAssert(c.value =~ rat, "\(c) != \(rat)")
			} else { XCTAssert(false, "\(a) is not a ConstantFunction") }
		}
	}
	
	func testDescription() {
		for _ in 0 ..< 100 {
			let a = (random() & 0xFF + 2).double // excludes special cases 0, 1
			let b = x^(random() & 0xF + 1).double
			let f = b / a
			XCTAssert(f.description == "\(1/a)\(b)", f.description)
		}
	}
}
