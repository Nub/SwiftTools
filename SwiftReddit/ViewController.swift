//
//  ViewController.swift
//  SwiftReddit
//
//  Created by Zachry Thayer on 6/3/14.
//  Copyright (c) 2014 Zachry Thayer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
	@IBOutlet var textView : UITextView
	
	override func viewDidLoad(){
		super.viewDidLoad()
		loadData()
	}

	
	func loadData(){
//		let redditURL = NSURL.URLWithTemplate("http://reddit.com/r/{subreddit}", values: ["subreddit":"motocross"])
//		redditURL.GET(){ (response: NSHTTPURLResponse, data: AnyObject) in
//			if data.isKindOfClass(NSError){
//				self.textView.text = "Error:\(data.description)"
//			} else {
//				let responseData = data as NSData
//				let text = NSString(data: responseData, encoding: NSUTF8StringEncoding)
//				self.textView.text = text
//			}
//		}
	}
	
	
}

