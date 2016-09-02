//
//  Polynomial.swift
//  LinearAlgebra
//
//  Created by Paul Kraft on 04.07.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct Polynomial < Number : Numeric > : BasicArithmetic, CustomStringConvertible {
	
	public var coefficients: [Number]
	
	public init(integerLiteral	: Int			) { self.init([Number(integerLiteral:	integerLiteral	)])	}
	public init(floatLiteral	: Double		) { self.init([Number(floatLiteral:		floatLiteral	)])	}
	public init(arrayLiteral	: Number...		) { self.init(arrayLiteral)									}
	public init()								  { self.init([0]) }
	public init(_ coefficients	: [Number] = []	) { self.coefficients = coefficients.count == 0 ? [0] : coefficients }
	
	public init(_ tuples: (coefficient: Number, exponent: Int)...) {
		self.coefficients = [0]
		for t in tuples { self[t.exponent] += t.coefficient }
	}
}

extension Polynomial { // calculus, derivative, integral
	
	public var derivative : Polynomial<Number> {
		if self.coefficients.count == 1 { return Polynomial([0]) }
		let c = self.coefficients.count - 1
		var coefficients = [Number](repeating: 0, count: c)
		for i in coefficients.indices {
			coefficients[i] = Number(integerLiteral: i + 1) * self.coefficients[i + 1]
		}
		return Polynomial(coefficients)
	}
	
	public var integral		: Polynomial<Number>	{ return integral(c: 0)							}
	
	public func integral(c index0: Number) -> Polynomial<Number> {
		let c = self.coefficients.count + 1
		var coefficients = [Number](repeating: 0, count: c)
		coefficients[0] = index0
		for i in self.coefficients.indices {
			coefficients[i + 1] = self.coefficients[i] / Number(integerLiteral: i + 1)
		}
		var p = Polynomial(coefficients)
		p.reduce()
		return p
	}
}

extension Polynomial { // reducing
	
	public var reduced		: Polynomial<Number>	{ var this = self; this.reduce(); return this	}
	
	public mutating func reduce() {
		let d = degree
		if d != coefficients.count - 1 { self.coefficients = self.coefficients[0...d] + [] }
	}
	
}

extension Polynomial { // descriptions
	
	public var latex		: String				{ return descString(latex: true)				}
	public var description	: String				{ return descString(latex: false)				}
	
	public var reverseDescription : String {
		let d = degree
		if d < 0 { return "0" }
		if d == 0 { return "\(coefficients[0].reducedDescription)" }
		let c0 = coefficients[0]
		var res = ""
		var hasOneInFront = false
		if c0 != 0 {
			res += coefficientDescription(first: !hasOneInFront)
			hasOneInFront = true
		}
		for i in 1 ... d {
			let ci = coefficients[i]
			if ci != 0 { res += ci.coefficientDescription(first: !hasOneInFront) + "x^\(i)" }
		}
		return res
	}
	
	private func descString(latex: Bool) -> String {
		var d = degree
		if d <= 0 { return "\(self[0].reducedDescription)" }
		let ci = coefficients[d]
		var res = "\(ci.coefficientDescription(first: true))x\(d == 1 ? "" : exp(latex: latex, d))"
		d -= 1
		while d > 0 {
			let ci = coefficients[d]
			if ci != 0 { res += " \(ci.coefficientDescription(first: false))x\(d == 1 ? "" : exp(latex: latex, d))" }
			d -= 1
		}
		let c0 = coefficients[0]
		if c0 != 0 { res += " \(c0 < 0 ? "-" : "+") \(c0.abs.reducedDescription)" }
		return res
	}
	
	private func exp(latex: Bool, _ d: Int) -> String { return latex ? "^{\(d)}" : "^\(d)" }
	
}

extension Polynomial {

	public var isZero		: Bool					{ return degree == 0 && coefficients[0] == 0	}

	public var hashValue	: Int {
		var h = 0
		for i in coefficients.indices {
			let hci = Double(coefficients[i].hashValue)
			let d = unsafeBitCast(hci, to: Int.self)
			let r = (h == 0 ? 1 : h) &* (d &+ i)
			h = h &+ r
		}
		return h
	}
	
	public var degree : Int {
		var i = self.coefficients.count - 1
		while i > 0 { guard self.coefficients[i] == 0 else { return i }; i -= 1 }
		return 0
	}
	
	public subscript(index: Int) -> Number {
		get {
			precondition(index >= 0, "precondition(index >= 0)")
			return index < coefficients.count ? coefficients[index] : 0
		}
		set {
			precondition(index >= 0, "precondition(index >= 0)")
			let count = coefficients.count
			if index >= count { coefficients.append(contentsOf: [Number](repeating: 0, count: index-count+1)) }
			coefficients[index] = newValue
		}
	}
	
	public func call(x: Number) -> Number? {
		var times : Number = 1, res : Number = 0
		for i in coefficients.indices {
			res += times * coefficients[i]
			times *= x
		}
		return res
	}
}

extension Polynomial where Number : Numeric {
	
	public var zeros : [Number] {
		// http://massmatics.de/merkzettel/index.php#!6:Nullstellenberechnung
		// TODO: still needs implementation, mostly done
		
		// print(self)
		
		var cs : [Number] = coefficients[0...degree] + []
		var zeros = [Number]()
		
		while cs.count > 0 && cs[0] == 0 {
			zeros.append(0)
			_ = cs.remove(at: 0)
		}
		
		switch cs.count - 1 {
		case -1:    return []
		case 0:     return zeros
		case 1:     return zeros + [-(cs[0] / cs[1])]
		// dividing by zero prohibited by degree calculation
		case 2:
			let det : Number = cs[1]*cs[1] - 4 * cs[0] * cs[2]
			if !(det is C) {
				// det = b^2 - 4ac
				if det < 0 { return zeros }
				if det == 0 { return zeros + [-cs[1] / ( 2 * cs[2] ) ] } // -b / 2a
			}
			let ds = det.sqrt
			let a = (-cs[1] + ds ) / ( 2 * cs[2] )
			let b = (-cs[1] - ds ) / ( 2 * cs[2] )
			return zeros + [a, b]
		default:
			let factors = Polynomial(cs).factors
			
			for f in factors {
				if f.degree < 3	{ zeros += f.zeros }
				guard f.degree >= 1 else { return zeros }
				var k = false
				for i in 1 ... f.degree {
					if f[i] != 0 {
						if !k { k = true }
						else { return zeros }
					}
					
				}
				let z = (-f[0]/f[f.degree]).power(1 / Double(f.degree))
				zeros.append(z)
				if f.degree % 2 == 0 { zeros.append(-z) }
			}
			return zeros
		}
	}
	
	public var factors : [Polynomial<Number>] {
		var cs : [Number] = coefficients[0...degree] + []
		var factors = [Polynomial<Number>]()
		var i = 0
		
		if cs.count > 0 {
			while i < cs.count && cs[i] == 0 { i += 1 }
			if i > 1 {
				cs = cs.dropFirst(i) + []
				factors.append(Polynomial<Number>((1, i)))
			}
		}
		
		var this = Polynomial(cs)
		
		if cs.count < 3 { return factors + [this] }
		if cs.count == 3 {
			let det : Number = cs[1]*cs[1] - 4 * cs[0] * cs[2]
			if !(det is C) {
				// det = b^2 - 4ac
				if det < 0 { return factors + [this] }
				if det == 0 {
					let n = -cs[1] / ( 2 * cs[2] )
					return factors + [Polynomial<Number>((n, 0), (1,1)),
					                  Polynomial<Number>((n, 0), (1,1))]
				} // -b / 2a
			}
			let ds = det.sqrt
			let a = (-cs[1] + ds ) / ( 2 * cs[2] )
			let b = (-cs[1] - ds ) / ( 2 * cs[2] )
			return factors + [Polynomial<Number>((a, 0), (1,1)),
			                  Polynomial<Number>((b, 0), (1,1))]
		}
		// source: http://www.math.utah.edu/~wortman/1050-text-fp.pdf
		
		let last = cs.last!
		for i in cs.indices { cs[i] /= last }
		if last != 1 { factors.append(Polynomial<Number>((last, 0))) }
		
		this = Polynomial(cs)
		
		let pfactors = cs[0].abs.primeFactors + [1]
		for i in 1 ..< cs.count - 1 {
			for pF in pfactors {
				let p = Number(integerLiteral: pF)
				
				// p
				let poly1 = Polynomial<Number>((p, 0), (1, i))
				let div1 = this /% poly1
				if div1.remainder.numerator.isZero {
					// print("agreeing on", div1, poly1, this, Polynomial(div1.numerator))
					factors.append(poly1)
					return factors + div1.result.factors
				}
				
				// -p
				let poly2 = Polynomial<Number>((-p, 0), (1, i))
				let div2 = this /% poly2
				if div2.remainder.numerator.isZero {
					factors.append(poly2)
					return factors + div2.result.factors
				}
			}
			// print(i)
		}
		return factors + [this]
	}
}

public func == < N : Numeric > (lhs: Polynomial<N>, rhs: Polynomial<N>) -> Bool {
	return lhs.reduced.coefficients == rhs.reduced.coefficients
}

infix operator	?=
public func		?= < N : Numeric > (lhs: Polynomial<N>, rhs: Polynomial<N>) -> [N] { return (lhs - rhs).zeros }


public func < < N : Numeric > (lhs: Polynomial<N>, rhs: Polynomial<N>) -> Bool {
	let r = rhs.coefficients.count
	let l = lhs.coefficients.count
	if l != r { return l < r }
	var i = l - 1
	while i >= 0 {
		let cmp = lhs.coefficients[i] - rhs.coefficients[i]
		if cmp < 0 { return true  }
		if cmp > 0 { return false }
		i -= 1
	}
	return false
}

public func += < N : Numeric > (lhs: inout Polynomial<N>, rhs: Polynomial<N>) {
	for i in 0 ... max(lhs.degree, rhs.degree) { lhs[i] += rhs[i] }
	lhs.reduce()
}

public func + < N : Numeric > (lhs: Polynomial<N>, rhs: Polynomial<N>) -> Polynomial<N> {
	var lhs = lhs; lhs += rhs; return lhs
}

public func - < N : Numeric > (lhs: Polynomial<N>, rhs: Polynomial<N>) -> Polynomial<N> {
	var lhs = lhs; lhs -= rhs; return lhs
}

public func -= < N : Numeric > (lhs: inout Polynomial<N>, rhs: Polynomial<N>) {
	for i in 0 ... max(lhs.degree, rhs.degree) { lhs[i] -= rhs[i] }
	lhs.reduce()
}

prefix public func - <N : Numeric> (lhs: Polynomial<N>) -> Polynomial<N> {
	var lhs = lhs
	for i in 0 ... lhs.degree { lhs[i] = -lhs[i] }
	return lhs
}

public func *= < N : Numeric > (lhs: inout Polynomial<N>, rhs: Polynomial<N>) {
	var res = Polynomial<N>([])
	for i in 0 ... lhs.degree {
		let l = lhs[i]
		if l != 0 {
			for j in 0 ... rhs.degree {
				let r = rhs[j]
				if r != 0 { res[i+j] += r * l } // example: (x^2 - x) * (x - 1) = x^3 - 2x^2 + x
			}
		}
	}
	res.reduce()
	lhs = res
}

public func * < N : Numeric > (lhs: Polynomial<N>, rhs: Polynomial<N>) -> Polynomial<N> {
	var res = lhs; res *= rhs; return res
}

infix operator /%

func % < N : Numeric > (lhs: Polynomial<N>, rhs: Polynomial<N>) -> (numerator: Polynomial<N>, denominator: Polynomial<N>) {
	// loses accuracy because ignoring rest, maybe adding another stored property to fit in rest?
	
	let ld = lhs.degree
	let rd = rhs.degree
	
	assert(rd != 0 || rhs[0] != 0)
	
	guard ld >= rd else { /* print("end:", lhs, rhs); */ return (lhs, rhs) }
	
	let coefficient = lhs[ld] / rhs[rd]
	let exponent = ld - rd
	var c = Polynomial<N>([0])
	c[exponent] = coefficient
	// print("before end:", lhs, rhs)
	let r = (lhs - (rhs * c)) % rhs
	// print("remainder:", r)
	return r
}

func /% < N : Numeric > (lhs: Polynomial<N>, rhs: Polynomial<N>) -> (result: Polynomial<N>, remainder: (numerator: Polynomial<N>, denominator: Polynomial<N>)) {
	// loses accuracy because ignoring rest, maybe adding another stored property to fit in rest?
	
	let ld = lhs.degree
	let rd = rhs.degree
	
	// print("start:", lhs, "/", rhs)
	
	assert(rd != 0 || rhs[0] != 0)
	
	guard ld >= rd else { return (0, (lhs, rhs)) }
	
	let coefficient = lhs[ld] / rhs[rd]
	let exponent = ld - rd
	var c = Polynomial<N>([0])
	c[exponent] = coefficient
	let res = ( (lhs - (rhs * c)) /% rhs)
	return (res.result + c, res.remainder)
	// print("end:", lhs, "/", rhs, "%:", lhs.remainder)
}

public func /= < N : Numeric > (lhs: inout Polynomial<N>, rhs: Polynomial<N>) {
	// loses accuracy because ignoring rest, maybe adding another stored property to fit in rest?
	
	let ld = lhs.degree
	let rd = rhs.degree
	
	// print("start:", lhs, "/", rhs)
	
	assert(rd != 0 || rhs[0] != 0)
	
	guard ld >= rd else { return }
	
	let coefficient = lhs[ld] / rhs[rd]
	let exponent = ld - rd
	var c = Polynomial<N>([0])
	c[exponent] = coefficient
	lhs = c + ( (lhs - (rhs * c)) / rhs);
	lhs.reduce()
	// print("end:", lhs, "/", rhs, "%:", lhs.remainder)
}

public func / < N : Numeric > (lhs: Polynomial<N>, rhs: Polynomial<N>) -> Polynomial<N> {
	var res = lhs
	res /= rhs
	return res
}



