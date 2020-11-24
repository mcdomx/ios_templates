//
//  TableTableViewController.swift
//  CoreDataExample
//
//  Created by Mark on 11/21/20.
//

import UIKit
import SwiftUI
import CoreData


class TableViewController: UITableViewController {
	
	let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
	var moc: NSManagedObjectContext?
	
	var items: [Item] = []
	var currentItem: Item?
	
	enum SegueType {
		case view
		case add
	}
	
	func setupDefaultItems() {
		let defaultItems: [[String:String]] =
			[
				["name": "item1", "attr1": "first attribute", "attr2": "second attribute"],
				["name": "item2", "attr1": "#1 attribute", "attr2": "#2 attribute"]
			]
		
		for item in defaultItems {
			
			// see if item already exists before adding
			do {
				let req = NSFetchRequest<Item>(entityName: "Item")
				req.predicate = NSPredicate(format: "name = %@", item["name"]!)
				let c = try moc!.fetch(req)
				if c.count == 0 {
					let newItem: Item = Item(context: moc!)
					newItem.name = item["name"]
					newItem.attribute1 = item["attr1"]
					newItem.attribute2 = item["attr2"]
					moc!.insert(newItem)
					appDelegate.saveContext()
				}
			} catch {
				print("Could not get result for fetch request.")
			}
		}
	}
	
	func loadItems() {
		do {
			let req = NSFetchRequest<Item>(entityName: "Item")
			items = try moc!.fetch(req)
		} catch {
			print("Could not get result for fetch request.")
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		loadItems()
		self.tableView.reloadData()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		moc = appDelegate.persistentContainer.viewContext
		
		// setup default db items
		self.setupDefaultItems()
		
		// now load the items in the db to the items list
		self.loadItems()
		
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
		
		let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addView))
		navigationItem.rightBarButtonItems = [self.editButtonItem, add]
		
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var count = 0
		
		do {
			let req = NSFetchRequest<Item>(entityName: "Item")
			count = try moc!.count(for: req)
		} catch {
			print("TableViewController: Could not get result for fetch request.")
		}
		
		return count //items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
		cell.textLabel?.text = items[indexPath.row].name

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
			do {
				let req = NSFetchRequest<Item>(entityName: "Item")
				req.predicate = NSPredicate(format: "name = %@", items[indexPath.row].name!)
				let c = try moc!.fetch(req)
				moc!.delete(c[0])
				appDelegate.saveContext()
				tableView.deleteRows(at: [indexPath], with: .fade)
			} catch {
				print ("TableViewController: Unable to delete item \(items[indexPath.row].name!)")
			}
			
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		currentItem = items[indexPath.row]
		performSegue(withIdentifier: "showItemDetail", sender: SegueType.view)
	}
	
	@objc func addView() {
		performSegue(withIdentifier: "addItemSegue", sender: SegueType.add)
	}
	
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		switch sender as! SegueType {
		case .view :
			if let itemViewController = segue.destination as? ItemViewController {
				itemViewController.selectedItem = currentItem
				itemViewController.appDelegate = self.appDelegate
			}
		case .add:
			if let addItemViewController = segue.destination as? AddItemViewController {
//				addItemViewController.appDelegate = self.appDelegate
			}
		}
		
	}
	
}
