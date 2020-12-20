// Playground to Load Data from CSV to CoreData DB

import SwiftCSV
import UIKit
import CoreData
import PlaygroundSupport

let dataURL_USConfirmed: String = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
let dataURL_GlobalConfirmed: String = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
let dataURL_USDeaths: String = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
let dataURL_GlobalDeaths: String = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"

func getContext() -> NSManagedObjectContext {
	
	// Define the ManagedObjectModel - get the model from the URLRequests.app
	let bundleURL = URL(fileURLWithPath: "/Users/markmcdonald/Desktop/ios_templates/URLRequests/URLRequests/DBLoad.playground/Resources/URLRequests.app")
	let bundle = Bundle(url: bundleURL)
	let modelURL = bundle!.url(forResource: "URLRequests", withExtension: "momd")
	let mom = NSManagedObjectModel(contentsOf: modelURL!)!
	
	
	
	// With the model, define the PersistentContainer
	// The PSC sets up the NSManagedObject contect
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


let context = getContext()

let us_uid = getEntity(name: "US_UID", context: context)
let us_stats = getEntity(name: "US_STATS", context: context)
let us_uid_attributes = us_uid!.attributesByName.map { $0.key }

var us_uid_types: [String:UInt] {
	var rvDict = [String:UInt]()
	let attrList: [[String: UInt]] = us_uid!.attributesByName.map { [$0.key:  $0.value.attributeType.rawValue] }
	
	// convert to a flat dictionary
	for a in attrList {
		for (k, v) in a {
			rvDict[k] = v
		}
	}
	return rvDict
}

func castAttrValue(key k: String, value v: String) -> [String:Any] {
	
	if us_uid_types.keys.contains(k.lowercased()) {
		switch NSAttributeType(rawValue: us_uid_types[k.lowercased()]!)! {
		case .stringAttributeType:
			return [k.lowercased():v]
		case .integer16AttributeType:
			return [k.lowercased():Int16(v)!]
		case .floatAttributeType:
			return [k.lowercased():Float(v)!]
		default:
			break
		}
	}
	return [k:v]
}

func castAttrValues(attrDict:[String:String]) -> [String:Any] {
	var rvDict = [String:Any]()
	for (k,v) in attrDict {
		rvDict.merge(castAttrValue(key: k, value: v), uniquingKeysWith: { (k,v) in return k })
	}
	return rvDict
}





func addUSUIDEntry(entry: [String:String]) -> Bool {
	
	// see if UID element is already in the DB
	let req = NSFetchRequest<NSFetchRequestResult>(entityName: "US_UID")
	
	if let uid = entry["UID"] {
		req.predicate = NSPredicate(format: "uid = %@", uid)
		let c = try! context.fetch(req)
		
		// no entries with uid exist
		if c.count == 0 {
			
			let ent = NSManagedObject(entity: us_uid!, insertInto: context)
			do {
				let addEntry = castAttrValues(attrDict: entry)
				ent.setValuesForKeys(addEntry)
				try context.save()
				return true
			} catch {
				print("uid already exists!")
				context.delete(ent)
				return false
			}
		}
	} else {
		print("No 'uid' in entry:")
		print(entry)
		
	}
	
	return false
}


let data_USConfirmed = try CSV(url: URL(string: dataURL_USConfirmed)!)



enum COVIDDataType {
	case confirmed
	case deaths
}

func getUSUIDDBEntry(uid: String) -> Any? {
	// see if UID element is already in the DB
	let req = NSFetchRequest<NSFetchRequestResult>(entityName: "US_UID")
	req.predicate = NSPredicate(format: "uid = %@", uid)
	do {
		return try context.fetch(req)
	} catch {
		return nil
	}
}


func addUSSTATSEntry(entry: [String:String], uid: String, dtype: COVIDDataType) -> [String:String] {
	// expects a dict of entries that look like ["11/30/2020": "260"]
	
	// return the entries that could not be added
	var rv = [String:String]()
	
	// set a date formatter
	let formatter = DateFormatter()
	formatter.dateFormat = "MM/dd/yy"
	
	for (k, v) in entry {
		// check that key is a date and value is an integer - skip if not
		let date = formatter.date(from: k)
		if let date = date, let val = Int(v) {
			let ent = NSManagedObject(entity: us_stats!, insertInto: context)
			do {
				ent.setValue(date, forKey: "date")
				
				switch dtype {
					case .confirmed:

						ent.setValue(val, forKey: "confirmed")
					case .deaths:
						ent.setValue(val, forKey: "deaths")
				}
				
				let uidEntry = getUSUIDDBEntry(uid: uid)!
				(uidEntry as AnyObject).setValue(ent, forKey: "stats")

				try context.save()

			} catch {
				print("could not add entry: '\(k):\(v)' for uid:\(uid) ")
				rv.updateValue(v, forKey: k)
				context.delete(ent)
			}
		}
			
	}
	return rv
}

//let rowAttrs = data_USConfirmed.namedRows[0].filter( { us_uid_attributes.contains($0.key.lowercased()) } )
//let rowValues = data_USConfirmed.namedRows[0].filter( { !rowAttrs.keys.contains($0.key) } )
//let failed = addUSSTATSEntry(entry: rowValues, uid: rowAttrs["UID"]!, dtype: COVIDDataType.confirmed)


func addData(data: [[String:String]]) {
	
	var uidAdded = 0
	var datesAdded = 0
	
	for row in data {
		let rowAttrs = row.filter( { us_uid_attributes.contains($0.key.lowercased()) } )
		let rowValues = row.filter( { !rowAttrs.keys.contains($0.key) } )

		let uidrv = addUSUIDEntry(entry: rowAttrs)
		let datesrv = addUSSTATSEntry(entry: rowValues, uid: rowAttrs["UID"]!, dtype: COVIDDataType.confirmed)
		
		if uidrv {
			uidAdded += 1
		}
		datesAdded += datesrv.count
		
	}
	
	print("Added UID's: \(uidAdded)")
	print("Added Dates: \(datesAdded)")
}

//addData(data: data_USConfirmed.namedRows)

let req = NSFetchRequest<NSFetchRequestResult>(entityName: "US_UID")
let all = try! context.fetch(req)

print(all)
