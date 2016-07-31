//
//  TrigonometricFunctions.swift
//  Math
//
//  Created by Paul Kraft on 29.07.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation


let sine    : CustomFunction = CustomFunction("sin(x)",
                                              function: { return sin($0) },
                                              integral: { return Equation(cosine, ConstantFunction(value: $0)) },
                                              derivate: { return Term(ConstantFunction(value: -1), cosine) })

let cosine  : CustomFunction = CustomFunction("cos(x)",
                                              function: { return cos($0) },
                                              integral: { return Equation(sine, ConstantFunction(value: $0)) },
                                              derivate: { return sine })

