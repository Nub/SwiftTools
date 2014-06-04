//
//  main.swift
//  swiftTools
//
//  Created by Zachry Thayer on 6/3/14.
//  Copyright (c) 2014 Zachry Thayer. All rights reserved.
//

import Foundation

//MARK: Test

println("Beginning NSURL_Networking test")

let testURL = NSURL.URLWithString("http://google.com")
testURL.fetch("GET", body: nil){
	(data: NSData) in
	let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as NSDictionary
	println("\(json.description)")
}

//Wait for the network to respond
for i in 1..5 {
	sleep(1)
}

println("Ending NSURL_Networking test")