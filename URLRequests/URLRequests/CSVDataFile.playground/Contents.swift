import SwiftCSV
import UIKit
import CoreData
import PlaygroundSupport

let dataURL_USConfirmed: String = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
let dataURL_GlobalConfirmed: String = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
let dataURL_USDeaths: String = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
let dataURL_GlobalDeaths: String = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"




let usProperties: [String: NSAttributeType] = [
						 "admin2": NSAttributeType.stringAttributeType,
						 "combined_key": NSAttributeType.stringAttributeType,
						 "confirmed": NSAttributeType.integer16AttributeType,
						 "country_region": NSAttributeType.stringAttributeType,
						 "date": NSAttributeType.dateAttributeType,
						 "deaths": NSAttributeType.integer16AttributeType,
						 "fips": NSAttributeType.stringAttributeType,
						 "iso2": NSAttributeType.stringAttributeType,
						 "iso3": NSAttributeType.stringAttributeType,
						 "code3": NSAttributeType.integer16AttributeType,
						 "lat": NSAttributeType.floatAttributeType,
						 "long_": NSAttributeType.floatAttributeType,
						 "province_state": NSAttributeType.stringAttributeType,
						 "uid": NSAttributeType.stringAttributeType]

var usEntity: NSEntityDescription {
	let rvEntity = NSEntityDescription()
	var props: [NSAttributeDescription] = []
	
	for (k,v) in usProperties {
		let a = NSAttributeDescription()
		a.name = k
		a.attributeType = v
		props.append(a)
	}
	
	rvEntity.name = "US"
	rvEntity.indexes = []
	rvEntity.properties = props
	
	return rvEntity
}

let globalProperties: [String: NSAttributeType] = [
	"confirmed": NSAttributeType.integer16AttributeType,
	"country_region": NSAttributeType.stringAttributeType,
	"date": NSAttributeType.dateAttributeType,
	"deaths": NSAttributeType.integer16AttributeType,
	"lat": NSAttributeType.floatAttributeType,
	"long_": NSAttributeType.floatAttributeType,
	"province_state": NSAttributeType.stringAttributeType]

var globalEntity: NSEntityDescription {
	let rvEntity = NSEntityDescription()
	var props: [NSAttributeDescription] = []
	
	for (k,v) in globalProperties {
		let a = NSAttributeDescription()
		a.name = k
		a.attributeType = v
		props.append(a)
	}
	
	rvEntity.name = "Global"
	rvEntity.indexes = []
	rvEntity.properties = props
	
	return rvEntity
}

func getContext() -> NSManagedObjectContext {
	
	// Define the ManagedObjectModel - get the model from the URLRequests.app
	let bundleURL = URL(fileURLWithPath: "/Users/markmcdonald/Desktop/ios_templates/URLRequests/URLRequests/CSVDataFile.playground/Resources/URLRequests.app")
	let bundle = Bundle(url: bundleURL)
	let modelURL = bundle!.url(forResource: "URLRequests", withExtension: "momd")
	let mom = NSManagedObjectModel(contentsOf: modelURL!)!
	
	
	
	// With the model, define the PersistentContainer
	// The PSC sets up the NSManagedObject datecontect
	let psc = NSPersistentContainer(name: "URLRequests", managedObjectModel: mom)

	// Setup the Store which will create the store coordinator
	// Data is stored within the bundle from where the Model came from in the first step
	psc.loadPersistentStores(completionHandler: { (storeDescription, error) in
		print(storeDescription.url?.absoluteString as Any)
		if let error = error as NSError? {
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
	})
	
	return psc.viewContext
}

func getEntity(name: String, context in: NSManagedObjectContext) -> NSEntityDescription? {
	let entities = context.persistentStoreCoordinator?.managedObjectModel.entities
	guard entities != nil else {
		print("no entities found")
		return nil
	}
	for e in entities! {
		if e.name == name {
			return e
		}
	}
	
	print("no entity matching: \(name)")
	print("Available entities: \(context.persistentStoreCoordinator!.managedObjectModel.entities.map( {$0.name!} ))")
	return nil
}



// clear all data in db
func clearEntity(entityName: String, context in: NSManagedObjectContext) {
	
	let entities = context.persistentStoreCoordinator!.managedObjectModel.entities.map( {$0.name!} )
	
	if !entities.contains(entityName) {
		print("Entity: '\(entityName)' is not valid. (\(entities) ")
		return
	}
	
	let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
	let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

	do {
		try context.execute(deleteRequest)
		try context.save()
		print("Deleted entity: \(entityName)")
	} catch let e as NSException {
		print("could not delte DB \(e.description)")
		print("could not delte DB \(entityName)")
	} catch {
		print("could not delte DB \(entityName)")
	}
}

func deleteDB(context: NSManagedObjectContext) {
	let entities = context.persistentStoreCoordinator!.managedObjectModel.entities.map( {$0.name!} )
	
	for e in entities {
		clearEntity(entityName: e, context: context)
	}
}

func loadData(dataRows: [[String:String]], entityName: String) {
	
	//first, clear the existing data entries
	clearEntity(entityName: entityName, context: context)
	
	// get the entity class
	let Entity = getEntity(name: entityName, context: context)
	
	// set a date formatter
	let formatter = DateFormatter()
	formatter.dateFormat = "MM/dd/yy"
	
//	var rowAttributes: [[String: Any]] = [[:]]
//	var rowValues: [[Date: Int]] = [[:]]
	
	for row in dataRows {
		
		var attributes: [String: Any] = [:]
		var values: [Date: Int] = [:]
		
		// get the respective entry data for each row of data
		// each row will contain multiple dat entries
		for (k, v) in row {
			let date = formatter.date(from: k)
			if let date = date, let val = Int(v) {
					values.updateValue(val, forKey: date)
			} else {
				attributes.updateValue(v, forKey: k.lowercased())
			}
		}
		
		// Convert the attrivute values to their respective type
		for (_ak, _av) in attributes {
			guard usProperties[_ak] != nil else {
				print(_ak, _av)
				continue
			}
			switch usProperties[_ak]! {
			case .integer16AttributeType:
				attributes[_ak] = Int(_av as! String)!
				break
			case .floatAttributeType:
				attributes[_ak] = Float(_av as! String)!
				break
			default:
				break
			}
		}
			
		// Now, create the entries
//		print("Creating entries .. ")
		for (_vk, _vv) in values {
			let ent = NSManagedObject(entity: Entity!, insertInto: context)
			ent.setValue(_vv, forKey: "confirmed")
			ent.setValue(_vk, forKey: "date")
			for (_ak, _av) in attributes {
				ent.setValue(_av, forKey: _ak)
			}
//			context.insert(ent)
		}
		
	}
	do {
		try context.save()
		print("saved context")
	} catch {
		print("could not save context!")
	}
}



func loadArray(dataRows: [[String:String]], entityName: String) {
	
	
	// get the entity class
	let Entity = getEntity(name: entityName, context: context)
	
	// set a date formatter
	let formatter = DateFormatter()
	formatter.dateFormat = "MM/dd/yy"
	
		var rowAttributes: [[String: Any]] = [[:]]
		var rowValues: [[Date: Int]] = [[:]]
	
	for row in dataRows {
		
		var attributes: [String: Any] = [:]
		var values: [Date: Int] = [:]
		
		// get the respective entry data for each row of data
		// each row will contain multiple dat entries
		for (k, v) in row {
			let date = formatter.date(from: k)
			if let date = date, let val = Int(v) {
				values.updateValue(val, forKey: date)
			} else {
				attributes.updateValue(v, forKey: k.lowercased())
			}
		}
		
		// Convert the attrivute values to their respective type
		for (_ak, _av) in attributes {
			guard usProperties[_ak] != nil else {
				print(_ak, _av)
				continue
			}
			switch usProperties[_ak]! {
			case .integer16AttributeType:
				attributes[_ak] = Int(_av as! String)!
				break
			case .floatAttributeType:
				attributes[_ak] = Float(_av as! String)!
				break
			default:
				break
			}
		}
		
		// Now, create the entries
		//		print("Creating entries .. ")
		for (_vk, _vv) in values {
			let ent = NSManagedObject(entity: Entity!, insertInto: context)
			ent.setValue(_vv, forKey: "confirmed")
			ent.setValue(_vk, forKey: "date")
			for (_ak, _av) in attributes {
				ent.setValue(_av, forKey: _ak)
			}
			//			context.insert(ent)
		}
		
	}
	do {
		try context.save()
		print("saved context")
	} catch {
		print("could not save context!")
	}
}





// get CSV data

//let data_GlobalConfirmed = try CSV(url: URL(string: dataURL_GlobalConfirmed)!)
// data_USConfirmed.header: [String]
// data_USConfirmed.namedRows: [[String: String]]
//print(data_USConfirmed.namedRows)

// Get the entity class definitions
//let entities = context.persistentStoreCoordinator?.managedObjectModel.entities
////print(entities!.map {$0.name})
//let US = entities![1]
//print(US)

let context = getContext()
let Entity = getEntity(name: "US", context: context)

print(Entity!.attributesByName["uid"]?.attributeValueClassName!)



//let data_USConfirmed = try CSV(url: URL(string: dataURL_USConfirmed)!)
//loadData(dataRows: data_USConfirmed.namedRows, entityName: "US")





//let ent = NSManagedObject(entity: US, insertInto: context)
//ent.setValue("Iowa", forKey: "province_state")
//
//try! context.save()


//loadData(dataRows: data_USConfirmed.namedRows, context: context, entityName: "US")

let req = NSFetchRequest<NSFetchRequestResult>(entityName: "US")
//let state = "Iowa"
//req.predicate = NSPredicate(format: "province_state = %@", state)
let c = try context.fetch(req)

print(c.count)

