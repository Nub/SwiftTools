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

//Mark: Test

let signal = Signal(){(object: AnyObject) -> AnyObject in
	let newObject = object as String + "A"
	println(newObject)
	return newObject
}

signal.next(){(object: AnyObject) -> AnyObject in
	let newObject = object as String + "B"
	println(newObject)
	return newObject
}.next(){(object: AnyObject) -> AnyObject in
	let newObject = object as String + "C"
	println(newObject)
	return newObject
}

signal.next(){(object: AnyObject) -> AnyObject in
	let newObject = object as String + "2"
	println(newObject)
	return newObject
}.filter(){(object: AnyObject) -> Bool in
	return false
}.next(){(object: AnyObject) -> AnyObject in
	let newObject = object as String + "3"
	println(newObject)
	return newObject
}

signal.sendNext("1")
