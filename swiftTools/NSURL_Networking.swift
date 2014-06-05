//
//  NSURL_Networking.swift
//  swiftTools
//
//  Created by Zachry Thayer on 6/3/14.
//  Copyright (c) 2014 Zachry Thayer. All rights reserved.
//

import Foundation

#if os(iOS)
	import UIKit
#elseif os(OSX)
	import AppKit
#endif

extension NSURL {
	//MARK: Networking
	struct Networking {
		
		static let operationQueue = NSOperationQueue.mainQueue()
		
		enum REST: String {
			case GET		= "GET"
			case POST		= "POST"
			case PUT		= "PUT"
			case DELETE		= "DELETE"
		}
		
		static let ErrorDomain = "NSURL_Networking"
		enum Error: Int {
			case ImageProcessingFailure = -1
			case JsonProcessingFailure = -2
		}
		
		static let ResponseKey = "response"
				
		#if os(iOS)
		static let imageType = UIImage.self
		#elseif os(OSX)
		static let imageType = NSImage.self
		#endif
		
		typealias HTTPHeaders = Dictionary<String,String>
		typealias HTTPBody = (NSData, Networking.HTTPHeaders)
		typealias Completion = ((NSHTTPURLResponse, AnyObject) -> Void)
	}
	
	func request() -> NSMutableURLRequest {
		let request = NSMutableURLRequest(URL: self)
		return request
	}
	
	func GET(body: Networking.HTTPBody, completion: Networking.Completion) {
		fetch(Networking.REST.GET, body: body, completion: completion)
	}
	
	func GET(completion: Networking.Completion) {
		fetch(Networking.REST.GET, body: nil, completion: completion)
	}

	func POST(body: Networking.HTTPBody, completion: Networking.Completion) {
		fetch(Networking.REST.POST, body: body, completion: completion)
	}
	
	func PUT(body: Networking.HTTPBody, completion: Networking.Completion) {
		fetch(Networking.REST.PUT, body: body, completion: completion)
	}
	
	func DELETE(body: Networking.HTTPBody, completion: Networking.Completion) {
		fetch(Networking.REST.DELETE, body: body, completion: completion)
	}
	
	func DELETE(completion: Networking.Completion) {
		fetch(Networking.REST.DELETE, body: nil, completion: completion)
	}
	
	func fetch(method: Networking.REST, body: Networking.HTTPBody!, completion: Networking.Completion) {
		let request = self.request()
		request.HTTPMethod = method.toRaw()
		
		if body != nil {
			let data = body.0
			let headerFieldValues = body.1
			request.HTTPBody = data;
			
			for key: String in headerFieldValues.keys {
				let value = headerFieldValues[key]
				request.setValue(value, forHTTPHeaderField: key)
			}
		}
		
		NSURLConnection.sendAsynchronousRequest(request, queue: Networking.operationQueue){(response: NSURLResponse!, data: NSData!, error: NSError!) in
			let httpResponse = response as NSHTTPURLResponse
			if error == nil {
				completion(httpResponse, data)
			} else {
				completion(httpResponse, error)
			}
		}
	}
	
	func processResponse(response: NSHTTPURLResponse, data: NSData) -> AnyObject {
		let mime: String = response.MIMEType
		var responseData: AnyObject!
		var error: NSError?

		switch mime {
		case "application/json":
			responseData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
		case let image where image.hasPrefix("image"):
			responseData = Networking.imageType(data: data as NSData)
			if response == nil {
				let userInfo = NSDictionary(object: response, forKey: Networking.ResponseKey)
				error = NSError(domain: Networking.ErrorDomain, code: Networking.Error.ImageProcessingFailure.toRaw(), userInfo: userInfo)
			}
		default:
			responseData = data
		}
		
		if error != nil {
			println("Response:\(response)\nError:\(error)")
			responseData = nil
		}
		
		return response
	}
	
	//MARK: URL Building
	
	/**
	* Builds urls based off of a template and a set of values
	* @param template - URL template format: Keys are defined as {key}, where key is a value from a dictionary
	* @param values - A dictionary of values to be injected into the template
	**/
	class func URLWithTemplate(template: String, values: Dictionary<String,String>) -> NSURL {
		var urlString = template
		for key: String in values.keys {
			let keyTemplate = "{\(key)}"
			let value = NSURL.escapeQueryString(values[key]!)
			urlString = urlString.stringByReplacingOccurrencesOfString(keyTemplate, withString: value)
		}
		
		return NSURL.URLWithString(urlString)
	}
	
	/**
	* Converts a dictionary into a GET query and appends it to a URL
	* @param quert - A dictionary of query parameters
	**/
	func URLByAppendingQuery(query: Dictionary<String, AnyObject>) -> NSURL {
		let queryString = NSURL.queryStringFromDictionary(query, baseName:nil)
		return NSURL(string: queryString)
	}
	
	//MARK: Private URL Building
	
	class func queryStringFromDictionary(dictionary: Dictionary<String, AnyObject>, baseName: String!) -> String {
		let escapedBasename = NSURL.escapeQueryString(baseName)
		var queryString = escapedBasename + "="
		var firstItem: Bool = (baseName != nil)
		
		for key: String in dictionary.keys {
			var escapedKey = NSURL.escapeQueryString(key)
			var value: AnyObject = dictionary[key] as AnyObject
			var newBaseName: String
			
			if firstItem {
				newBaseName = escapedKey
			} else {
				queryString += "&"
				newBaseName = "\(escapedBasename)[\(escapedKey)]"
			}
			
			if value is Dictionary<String, AnyObject> {
				let dictionaryQueryString = NSURL.queryStringFromDictionary(value as Dictionary<String, AnyObject>, baseName: newBaseName)
				queryString += dictionaryQueryString
				continue
			} else if value is Array<String> {
				let dictionaryQueryString = NSURL.queryStringFromDictionary(value as Dictionary<String, AnyObject>, baseName: newBaseName)
				queryString += dictionaryQueryString
				continue
			} else {
				let escapedValue = NSURL.escapeQueryString("\(value)")
				if baseName != nil {
					queryString += "\(escapedBasename)[\(escapedKey)]=\(escapedValue)"
				} else {
					queryString += "\(escapedKey)=\(escapedValue)"
				}
			}
			
			firstItem = false
		}
		
		return queryString
	}
	
	class func queryStringFromArray(array: Array<String>, baseName: String) -> String {
		let escapedKey = NSURL.escapeQueryString(baseName)
		var queryString = escapedKey + "="
		
		for value: String in array {
			let escapedValue = NSURL.escapeQueryString(value)
			queryString += escapedValue
			
			if value != array[array.endIndex] {
				queryString += ","
			}
		}
		
		return queryString
	}
	
	class func escapeQueryString(queryString: String) -> String {
		let allowedCharacters = NSCharacterSet(charactersInString: ":/?#[]@!$&’()*+,;=")
		return queryString.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
	}
	
}

//MARK: Operator overloading

@infix func + (left: NSURL, right: Dictionary<String, AnyObject>) -> NSURL {
	return left.URLByAppendingQuery(right)
}
