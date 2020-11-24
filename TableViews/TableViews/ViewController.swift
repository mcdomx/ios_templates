//
//  ViewController.swift
//  TableViews
//
//  Created by Mark on 11/19/20.
//

import UIKit

class ViewController: UIViewController {
	
	var state: String = ""

	@IBOutlet weak var navItem: UINavigationItem!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navItem.title = state
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navItem.title = state
	}


}

