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

//Mark: Test

let signal = Signal(){(object: AnyObject) -> AnyObject in
	let newObject = object as String + "A"
	println(newObject)
	return newObject
}

signal.subscribeNext(){(object: AnyObject) -> AnyObject in
	let newObject = object as String + "B"
	println(newObject)
	return newObject
}.subscribeNext(){(object: AnyObject) -> AnyObject in
	let newObject = object as String + "2"
	println(newObject)
	return newObject
}

signal.subscribeNext(){(object: AnyObject) -> AnyObject in
	let newObject = object as String + "C"
	println(newObject)
	return newObject
}

signal.sendNext("1")
