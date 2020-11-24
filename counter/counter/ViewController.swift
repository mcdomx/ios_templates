//
//  ViewController.swift
//  volumeButtonInput
//
//  Created by Mark on 11/24/20.
//

import UIKit
import Charts
import TinyConstraints


class ViewController: UIViewController {
	
	
	@IBOutlet weak var graphCardView: UIStackView!
	@IBOutlet weak var countValue: UILabel!
	@IBAction func decrButton(_ sender: Any) {
		if count > 0 {
			count -= 1
			countValue.text = "\(count)"
		}
	}
	@IBAction func incrButton(_ sender: Any) {
		count += 1
		countValue.text = "\(count)"
	}
	
	var count: Int = 0
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		countValue.text = "\(count)"
		
		
		
	}


}

