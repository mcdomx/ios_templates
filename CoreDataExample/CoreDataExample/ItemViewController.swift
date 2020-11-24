//
//  ItemViewController.swift
//  CoreDataExample
//
//  Created by Mark on 11/21/20.
//

import UIKit
import CoreData

class ItemViewController: UIViewController {
	
	var appDelegate: AppDelegate?
	var selectedItem: Item?

	@IBOutlet weak var itemName: UILabel!
	@IBOutlet weak var itemAttr1: UILabel!
	@IBOutlet weak var itemAttr2: UILabel!
//	@IBOutlet weak var editItemButton: UIButton!
	@IBAction func editItemButton(_ sender: Any) {
		performSegue(withIdentifier: "editItem", sender: nil)
	}
	
	func updateLabels() {
		itemName.text = selectedItem?.name
		itemAttr1.text = selectedItem?.attribute1
		itemAttr2.text = selectedItem?.attribute2
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		updateLabels()
        
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateLabels()
	}
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		if let itemEditController = segue.destination as? EditItemViewController {
			itemEditController.selectedItem = selectedItem
		}
	
	}

}
