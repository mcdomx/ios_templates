//
//  ViewController.swift
//  URLRequests
//
//  Created by Mark on 11/25/20.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var urlField: UITextField!
	
	@IBAction func retrieveDataButton(_ sender: Any) {
		performSegue(withIdentifier: "showData", sender: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		urlField.text = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/11-24-2020.csv"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? DataViewController {
			vc.url = URL(string: urlField.text!)
		}
	}


}

