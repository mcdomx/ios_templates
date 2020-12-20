//
//  USStatesTableViewController.swift
//  COVIDTracker
//
//  Created by Mark on 12/19/20.
//

import UIKit
import COVIDData

class USStatesTableViewController: UITableViewController {

	let states = COVIDData.states!
	var selectedState: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return states.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		cell.textLabel?.text = states[indexPath.row]
		
		return cell
	}

	// MARK: - Navigation
	
	// handle the seque when clicking a state
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedState = states[indexPath.row]
		performSegue(withIdentifier: "showState", sender: nil)
	}
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destination.
		// Pass the selected object to the new view controller.
		if let viewController = segue.destination as? SelectedStateViewController {
			viewController.state = selectedState
		}
	}
}
