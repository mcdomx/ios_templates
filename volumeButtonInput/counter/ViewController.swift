//
//  ViewController.swift
//  volumeButtonInput
//
//  Created by Mark on 11/24/20.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

	
	@IBOutlet weak var countValue: UILabel!
	
	var count: Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		countValue.text = "\(count)"
		// Do any additional setup after loading the view.
	}


}

