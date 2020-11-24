//
//  EditItemViewController.swift
//  CoreDataExample
//
//  Created by Mark on 11/23/20.
//

import UIKit
import CoreData

class EditItemViewController: UIViewController, UITextFieldDelegate {

	let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
	var selectedItem: Item?
	
	@IBOutlet weak var editNameField: UITextField!
	@IBOutlet weak var editAttr1Field: UITextField!
	@IBOutlet weak var editAttr2Field: UITextField!
	@IBAction func saveButton(_ sender: Any) {
		saveChanges()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		editNameField.text = selectedItem!.name
		editAttr1Field.text = selectedItem!.attribute1
		editAttr2Field.text = selectedItem!.attribute2
		
		let saveItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveChanges))
		navigationItem.rightBarButtonItem = saveItem
		
		for f in [editNameField, editAttr1Field, editAttr2Field] {
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
	
	@objc func saveChanges() {
		selectedItem!.name = editNameField.text
		selectedItem!.attribute1 = editAttr1Field.text
		selectedItem!.attribute2 = editAttr2Field.text
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
