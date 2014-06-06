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
	typealias BoolClosure = (AnyObject -> Bool)
	
	
	var subscribers = Signal[]()
	var closure: SignalClosure!
	var filterClosure: BoolClosure = {(object: AnyObject) in return false}
	var currentValue: AnyObject!
	
	init () {}
	
	init (_closure: SignalClosure) {
		closure = _closure
	}
	
	func sendNext(object: AnyObject) {
		
		if filterClosure(object) {return}
		
		if	closure {
			currentValue = closure(object)
		} else {
			currentValue = object
		}
		for signal: Signal in subscribers {
			signal.sendNext(currentValue)
		}
	}
	
	func next(_closure: SignalClosure) -> Signal {
		let newSignal = Signal()
		newSignal.closure = _closure
		subscribers.append(newSignal)
		return newSignal
	}
	
	func filter(_filter: BoolClosure) -> Signal {
		let newSignal = Signal()
		newSignal.closure = {return $0}
		newSignal.filterClosure = _filter
		subscribers.append(newSignal)
		return newSignal
	}
}