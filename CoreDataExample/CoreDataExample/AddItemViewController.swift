//
//  AddItemViewController.swift
//  CoreDataExample
//
//  Created by Mark on 11/22/20.
//

import UIKit
import CoreData

class AddItemViewController: UIViewController, UITextFieldDelegate {

	let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
	var moc: NSManagedObjectContext?
	
	@IBOutlet weak var addName: UITextField!
	@IBOutlet weak var addAttr1: UITextField!
	@IBOutlet weak var addAttr2: UITextField!
	@IBAction func addItemButton(_ sender: Any) {
		addItem()
	}
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		moc = appDelegate.persistentContainer.viewContext
		
		let add = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(self.addItem))
		navigationItem.rightBarButtonItem = add
		
		for f in [addName, addAttr1, addAttr2] {
			f?.delegate = self
			f?.addTarget(f, action: #selector(becomeFirstResponder), for: .touchUpInside)
		}
		
    }
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		view.endEditing(true)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
		return false
	}
	
	
	@objc func addItem() {
		let newItem: Item = Item(context: moc!)
		newItem.name = addName.text
		newItem.attribute1 = addAttr1.text
		newItem.attribute2 = addAttr2.text
		moc!.insert(newItem)
		appDelegate.saveContext()
		
		self.navigationController?.popViewController(animated: true)
		self.parent?.viewWillAppear(true)
		
	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
