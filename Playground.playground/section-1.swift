// Playground - noun: a place where people can play

import Cocoa

println("Test")

var error: NSErrorPointer = UnsafePointer<NSError?>()
let errorObject = NSError(domain: "Test", code: Int(-1), userInfo: ["test":"test"])

error.memory = errorObject

println("\(error)")