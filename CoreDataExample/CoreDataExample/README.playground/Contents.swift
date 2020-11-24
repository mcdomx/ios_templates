/*:
### IOS Core Data
---
ref: https://www.raywenderlich.com/9335365-core-data-with-swiftui-tutorial-getting-started

https://developer.apple.com/documentation/coredata

+ This will be a basic CRUD application that uses Core Data to persist information.
+ CoreData provides ORM-like access to database objects in the MacOS and IOS landscape.
+ In order to persist data, the Core Data stack of objects need to be initialized.
+ Core Data in macOS and IOS are handled differently.  This document focuses on IOS Core Data.
+ In addition to COre Data concepts, this example project also includes handing seque changes, keyboard display and dismissing, navigation contoller and navigation coller buttons.


#### Terms
---
##### Core Data Stack
Core Data relies on a 'stack' of 4 classes to manage data and the data stack:

##### 1. NSPersistentContainer
- Top level object that contains the 3 parts of the stack listed below.
- If you can gain access to the `NSPersistentContainer`, you can access the following stack elements:

##### 2. NSManagedObjectModel
- First step in stack initalization.
- Includes a description of the data schema and creates class definitions of the data from the data as it is defined int he data schema.

##### 3. NSPersistentStoreCoordinator
- Second item to be initilized.
- Instantiates instances of the managed object model.  Once intantiated, the `NSPersistentStoreCoordinator` will pass objects to the `NSManagedObjectContext`.

##### 4. NSManagedObjectConext
- This will be the primary application interface to the stored data.
- Acts as an intermediary step for data so that any changes made to data in the `NSanagedObjectContext` will be to be explicielty saved bfore they persist.


#### Create a Project with Core Data
A project can be initially created with the respective Core Data components, or the Core Data components can be added after an application has been created.  Generally, it will be easier to create a project with Core Data to start with.

In this example project, we will use a TableView to display data elements.  This tutorial will use the TableView tutorial as a base for adding Core Data.  Any changes necessary to that tutorial are explained here.

#### Create a Schema
If you started the project with Core Data, you will have a `*.xcdatamodel`file in the project.  If you don't have that file, add a `Data Model` to the project.
1. Open the `*.xcdatamodeld` file.
2. Adding an `Entity` is like adding a table.
3. `Attributes` are the fields of a table.
4. `Relationships` can be added to define primary key relationships between entities.

By default, XCode will use SQlite as the default backend database.

#### Initializing the Stack
The Core Data stack will need to be initialized. If you selected `Core Data` during the project setup, the code for the initialization is in the AppDelegate.swift file, otherwise, you will need to add it in the `AppDelegate` class:

*/

// MARK: - Core Data stack

lazy var persistentContainer: NSPersistentContainer = {
	/*
	The persistent container for the application. This implementation
	creates and returns a container, having loaded the store for the
	application to it. This property is optional since there are legitimate
	error conditions that could cause the creation of the store to fail.
	*/
	let container = NSPersistentContainer(name: "CoreDataExample")
	container.loadPersistentStores(completionHandler: { (storeDescription, error) in
		if let error = error as NSError? {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			
			/*
			Typical reasons for an error here include:
			* The parent directory does not exist, cannot be created, or disallows writing.
			* The persistent store is not accessible, due to permissions or data protection when the device is locked.
			* The device is out of space.
			* The store could not be migrated to the current model version.
			Check the error message to determine what the actual problem was.
			*/
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
	})
	return container
}()

// MARK: - Core Data Saving support

func saveContext () {
	let context = persistentContainer.viewContext
	if context.hasChanges {
		do {
			try context.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
}


/**
#### Using the Application's Data Store Across Classes and Scenes
To add, edit or delete items from the database, we will need to access the same instance of the database across multiple classes in the application.  As shown in the previous step, the `NSManagedObjectContext` is defined with the relative componets within the AppDelegate class.  This class is a singleton class for the entire application and is the single point of contact to the application.  We cab access this singleton using the following:

*/

let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

/**

Within the appDelegate variable defined above, we can find `appDeledate,persistentContainer` which contains `appDelegate,persistentContainer.viewContext` which represents the application's `NSManagedObjectContext`.

*/

let moc = appDelegate.persistentContainer.vewContext

/**
#### Saving Data Upon Exit
If you initiated the project as a Core Data project, the `SceneDelegate.swift` file will include a call to the saveContext() function in the AppDelegate when the application is closed or loses focus.  This will persist any data that was added, deleted, or changed in the `NSManagedObjectContext` object.

The `SceneDelegate.swift` code:
*/
func sceneDidEnterBackground(_ scene: UIScene) {
	(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
}

/**
#### Using the DataBase - Adding Data
Here, we discuss adding entries to the database

- In whichever viewcontroller that you want to use to add data, get the persistentContainer variable from the AppDelegate class:
*/

import CoreData

let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
let moc: NSManagedObjectContext = appDelegate.persistentContainer.viewContext

// assumes the Item is a 'table' in the data schema with attributes 'name', 'attribute1' and 'attribute2'
var newItem: Item = Item(context: moc)
newItem.name = item["name"]
newItem.attribute1 = item["attr1"]
newItem.attribute2 = item["attr2"]
moc.insert(newItem)
appDelegate.saveContext()

/**
#### Using the DataBase - Retrieving Data
This is where Core Data is different from IOS to macOS.  IOS uses `NSFetchRequest` to retrieve data and `NSPredicate` to filter the database items returned. `NSFetchRequest` allows items to be used directly in views.

Because `fetch` throws an error on failure, it must be wrapped in a do-try-catch pattern.

*/
do {
	let req = NSFetchRequest<Item>(entityName: "Item")
	req.predicate = NSPredicate(format: "name = %@", item["name"]!)
	let c = try moc.fetch(req)
} catch {
	print("Unable to fetch data!")
}

/**
#### Adding new elements to the data base
To create new db items, an empty `NSManagedObject` is created and new attributes are assigned, before inserting the item into the `NSManagedObjectContext` and then saving the context.
*/

let newItem: Item = Item(context: moc!)
newItem.name = "new name"
newItem.attribute1 = "attribute 1"
newItem.attribute2 = "attribute 2"
moc!.insert(newItem)
appDelagate.saveContext()

/**
#### Saving updates to an existing data element
Once an item has been retrieved from the data base, it can be modified.  When it is modified, the modifications are stored in the temporary `NSManagedObjectContect`.  To save to the database, the `NSManagedObjectContext` must be saved.

*/
do {
	let req = NSFetchRequest<Item>(entityName: "Item")
	req.predicate = NSPredicate(format: "name = %@", item["name"]!)
	let c = try moc.fetch(req)
	c.name = "changed name"
	appDelegate.saveContext()
} catch {
	print("Unable to fetch data!")
}

