//
//  Signal.swift
//  swiftTools
//
//  Created by Zachry Thayer on 6/5/14.
//  Copyright (c) 2014 Zachry Thayer. All rights reserved.
//

import Foundation

class Signal {
	typealias SignalClosure = (AnyObject -> AnyObject)
	
	var subscribers = Signal[]()
	var closure: SignalClosure!
	var currentValue: AnyObject!
	
	init () {}
	
	init (_closure: SignalClosure) {
		closure = _closure
	}
	
	func sendNext(object: AnyObject) {
		if	closure {
			currentValue = closure(object)
		} else {
			currentValue = object
		}
		for signal: Signal in subscribers {
			signal.sendNext(currentValue)
		}
	}
	
	func subscribeNext(_closure: SignalClosure) -> Signal {
		let newSignal = Signal()
		newSignal.closure = _closure
		subscribers.append(newSignal)
		return newSignal
	}
}