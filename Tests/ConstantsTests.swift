//
//  ConstantsTest.swift
//  Math
//
//  Created by Paul Kraft on 29.07.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import XCTest
import Math

class ConstantsTest: XCTestCase {
	
	func testEverything() {
		print("pi:         ", Constants.pi)
		XCTAssert(Constants.pi == Double.pi)
		print("-----------------------------------------------------")
		print("tau:        ", Constants.tau)
		XCTAssert(Constants.tau == Double.pi * 2)
		print("-----------------------------------------------------")
		print("e:          ", Constants.Math.e)
		print("-----------------------------------------------------")
		print("gamma:      ", Constants.Math.gamma)
		print("-----------------------------------------------------")
		print("i:          ", Constants.Math.i)
		print("-----------------------------------------------------")
		print("goldenRatio:", Constants.Math.goldenRatio)
		print("-----------------------------------------------------")
		print("c:          ", Constants.Physics.c)
		print("-----------------------------------------------------")
		print("e:          ", Constants.Physics.e)
		print("-----------------------------------------------------")
		print("G:          ", Constants.Physics.G)
		print("-----------------------------------------------------")
		print("h:          ", Constants.Physics.h)
		print("-----------------------------------------------------")
		print("e_0:        ", Constants.Physics.e_0)
		print("-----------------------------------------------------")
		print("h_:         ", Constants.Physics.h_)
		print("-----------------------------------------------------")
		print("y_0:        ", Constants.Physics.y_0)
	}
	
}

extension ConstantsTest {
	static var allTests : [(String, (ConstantsTest) -> () throws -> Void)] {
		return [
			("testEverything", testEverything)
		]
	}
}