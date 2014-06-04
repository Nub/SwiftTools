//
//  NSURL_Networking.swift
//  swiftTools
//
//  Created by Zachry Thayer on 6/3/14.
//  Copyright (c) 2014 Zachry Thayer. All rights reserved.
//

import Foundation

extension NSURL {
	struct Networking {
		static let operationQueue = NSOperationQueue.mainQueue()
		static let mimeHTTPHeaderField = "Content-Type"
	}
	
	func request() -> NSMutableURLRequest {
		let request = NSMutableURLRequest(URL: self)
		return request
	}
	
	func fetch(method: String, body: (NSString, NSData)!, completion: ((NSHTTPURLResponse, AnyObject) -> Void)) {
		let request = self.request()
		request.HTTPMethod = method
		
		if body != nil {
			let mime = body.0
			let data = body.1
			request.setValue(mime, forHTTPHeaderField: Networking.mimeHTTPHeaderField)
			request.HTTPBody = data;
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
	
	//MARK: URL Building
	
	class func URLWithTemplate(template: String, values: Dictionary<String,String>) -> NSURL {
		var urlString = template
		for key: String in values.keys {
			let keyTemplate = "{\(key)}"
			let value = NSURL.escapeQueryString(values[key]!)
			urlString = urlString.stringByReplacingOccurrencesOfString(keyTemplate, withString: value)
		}
		
		return NSURL.URLWithString(urlString)
	}
	
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
	
	func URLByAppendingQuery(query: Dictionary<String, AnyObject>) -> NSURL {
		let queryString = NSURL.queryStringFromDictionary(query, baseName:nil)
		return NSURL(string: queryString)
	}

}


//MARK: Operator overloading

@infix func + (left: NSURL, right: Dictionary<String, AnyObject>) -> NSURL {
	return left.URLByAppendingQuery(right)
}
