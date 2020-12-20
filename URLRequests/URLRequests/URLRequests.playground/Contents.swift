import UIKit
/*:

# URLRequests
This application will explore handling URL data and file requests using Swift.

### References:
["Apple Developer - URL Loading System"](https://developer.apple.com/documentation/foundation/url_loading_system)

### Overview
A heirarchy of classes are used to define and execute URL requests.  `URLSession` is the top level object used in the heirarchy.  A session is defined with a `URLSessionConfiguration` before the session is used to create session tasks.

Within this heirarchy, various options are available to define the behavior of the session requests which is ultimately determined by what the objective is.

![Core Data Stack](URLSession.png)

#### 1. Create a URL object
A `URL` will defined the URL string address:
*/

var url1 = URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/11-24-2020.csv")!

var url = URL(string: "https://api.github.com/repos/CSSEGISandData/COVID-19/contents/csse_covid_19_data/csse_covid_19_daily_reports?ref=master")!


/*:

#### 2. Create a Session
At this point, there are a few options.
1) If there are no special needs, the default, singleton, session object can be used.  You can use the default and skip to the next step where the defulat session is referred to.

*/
let sharedSession = URLSession.shared
/*:

If you choose this path, you cannot change the URLSessionConfiguration.  Below is a function that will take advantage of the sharedSession:

*/
var rvData1 = NSMutableData()

func startLoad() {
	rvData1 = NSMutableData()
//	let taskDL = URLSession.shared.downloadTask(with: url)
	let task = URLSession.shared.dataTask(with: url) {
		data, response, error in
		
		if let data = data,
		   let string = String(data: data, encoding: .utf8) {
			DispatchQueue.main.async {
				rvData1.append(data)
			}
		}
	}
	task.resume()
}

startLoad()
print(rvData1.count)
/*:

2) If the URL should receive data in the background or if you intend to create a `URLSession` (instead of the default session indicated above) within a `URLSessionDataDelegate` class.  The delegate class will handle callbacks from the session.  When creating a `URLSession`, a `URLSessionConfiguration` must be defined; however, the default, singleton, configuration can be used; `URLSessionConfiguration.default`.   Any session that is created can be reused in multiple tasks.

The `URLSessionDataDelegate` is called when the session receives data from a task that has been initated.

Note that you can include the `URLSessionDataDelegate` in a View class which is associated with a storyboard view.

*/
// Download Example
public func downloadFile(url: String) throws -> URL {
	let sourceURL = URL(string: url)!
	let destinationURL = Bundle.main.resourceURL!.appendingPathComponent(sourceURL.lastPathComponent)
	
	let sessionConfig = URLSessionConfiguration.default
	sessionConfig.waitsForConnectivity = true
	sessionConfig.allowsCellularAccess = true
	
	let session = URLSession(configuration: sessionConfig)
	
	let request = URLRequest(url: sourceURL)
	
	let task = session.downloadTask(with: request) {
		(tempLocalURL, response, error) in
		if let tempLocalURL = tempLocalURL, error == nil {
			// success
			if let statusCode = (response as? HTTPURLResponse)?.statusCode {
				print("Download Success (\(statusCode)")
			}
			
			// move from temp location to final destination
			do {
				// delete file if it exists
				if FileManager.default.isDeletableFile(atPath: destinationURL.path) {
					try FileManager.default.removeItem(at: destinationURL)
				}
				
				try FileManager.default.moveItem(at: tempLocalURL, to: destinationURL)
				
				print("File is available at:")
				print("\(destinationURL)")
			} catch {
				print("Unable to move file:")
				print("\tfrom: \(tempLocalURL)")
				print("\tto: \(destinationURL)")
			}
			
		} else {
			print("Download Error:")
			print("\(error!.localizedDescription)")
		}
	}
	
	task.resume()
	
	while !task.progress.isFinished {
		sleep(1)
	}
	
	if !(try destinationURL.checkResourceIsReachable()) {
		print("File wasn't downloaded") //throw error here
	}
	
	return destinationURL
}




// This class can implement several other respective delegates:
// URLSessionDelegate, URLSessionTaskDelegate and URLSessionDownloadDelegate
class SessionDelegate: NSObject, URLSessionDataDelegate {
	
	lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.default
		configuration.waitsForConnectivity = true
		configuration.allowsCellularAccess = true
		return URLSession(configuration: configuration,
						  delegate: self, delegateQueue: nil)
	}()
	
	var receivedData: NSMutableData?
	
	convenience init(receivedData: inout NSMutableData) {
		self.init()
		self.receivedData = receivedData
	}
	
	// URLSessionDataDelegate function called when session receives data
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		self.receivedData!.append(data)
	}
	
	func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
		print("Session killed: \(error!.localizedDescription.description)")
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
//		print("Finished receiving data: \(metrics)")
		print("---------REQUEST IS COMPLETE---------")
		print("----STATUS CODE: \((task.response as! HTTPURLResponse).statusCode)----")
	}
	
}

/*:
#### 3. Create a Task
A task is essentially, the URL request.  You can define a task without calling it.  You must call `resume()` on the task object to execute the request.
1) `URLSessionDataTask` - receive data into memory.
2) `URLSessionDownloadTask` - receive data into file in local file system.

*/

// This will extract the downloaded data into a Json list of dictionary elements
//var jsonValues: [[String: Any]]?
//do {
//	jsonValues = try JSONSerialization.jsonObject(with: receivedData as Data, options: []) as? [[String: Any]]
//} catch {
//	print("could not jsonify")
//}

// Even better, you can decode the downloaded data directory into a data structure
// making this struct `Codable` will allow the Json object to be cast into this object
struct DBEntry: Codable {
	var sha: String = ""
	var path: String = ""
	var name: String = ""
	var type: String = ""
	var html_url: String = ""
	var _links: [String: String] = [:]
	var size: Int = 0
	var git_url: String = ""
	var download_url: String = ""
	var url: String = ""
	
}

// Decode data directly into Object type
//var entries: [DBEntry]?
//do {
//	entries = try JSONDecoder().decode([DBEntry].self, from: receivedData as Data)
//	print(entries![entries!.count-1])
//} catch {
//	print("could not decode")
//}


// We don't need all the data that was provided in the initial Json object
// We will use the initial struct as an intermediary object to filter out unneeded data
// Define a struct that looks like what we really want.

struct DataFile: Codable {
	var name: String
	var url: URL
	var date: Date
	
	init(from decoder: DBEntry) {
		name = decoder.name
		url = URL(string: decoder.download_url) ?? URL(string: "")!
		
		let dformatter = DateFormatter()
		dformatter.dateFormat = "MM-dd-yyyy"
		date = dformatter.date(from: { decoder.name.components(separatedBy: ".")[0] }()) ?? Date(timeIntervalSince1970: 0)
	}
}

func getMostRecentFileURL(fileURL: URL) -> URL {
	
	var receivedData = NSMutableData()
	var rvURL: URL?
	let session = SessionDelegate(receivedData: &receivedData)
	
	func handler(data: Data?, response: URLResponse?, err: Error?) {
		if err != nil {
			print("got an error handling url request")
			return
		}
		
		guard let httpResponse = response as? HTTPURLResponse,
			  (200...299).contains(httpResponse.statusCode) else {
			print("got non-OK response: \((response as! HTTPURLResponse).statusCode)")
			return
		}
		
		if data != nil {
			// deocode received data directly into DBEntry objects
			var entries: [DBEntry]?
			do {
				entries = try JSONDecoder().decode([DBEntry].self, from: data!)
			} catch {
				print("could not decode")
			}

			// map DBEntry entries to a DataFile objects and remove anything that is not a csv file
			let dataFiles = entries!.map({ DataFile(from: $0) }).filter({ $0.name.hasSuffix(".csv") })
			
			// Find entry with most recent date
			var mostRecent: DataFile = dataFiles[0]
			for f in dataFiles[1...] {
				if f.date >= mostRecent.date {
					mostRecent = f
				}
			}
		
			rvURL = mostRecent.url
			return
		}
	}
	
	let task = session.session.dataTask(with: fileURL, completionHandler: handler)  // loads data into memory
	task.resume()
	
	while rvURL == nil {
		sleep(1)
	}
	return rvURL!
}

let dataURL = getMostRecentFileURL(fileURL: url)
print(dataURL)

// Now get the data from the file of the most recent entry
func getLatestData(dataURL: URL) -> Data? {
	
	var receivedData = NSMutableData()
//	var rvValues: [[String: Any]]?
//	var rvString: String = ""
	var rvData: Data?
	let dataURL: URL = dataURL
	let session = SessionDelegate(receivedData: &receivedData)
	
	func handler(data: Data?, response: URLResponse?, err: Error?) {
		if err != nil {
			print("got an error handling url request")
			return
		}
		
		guard let httpResponse = response as? HTTPURLResponse,
			  (200...299).contains(httpResponse.statusCode) else {
			print("got non-OK response: \((response as! HTTPURLResponse).statusCode)")
			return
		}
		
		if data != nil {
			
//			do {
//				rvValues = try (JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]])
//				let string = String(data: data!, encoding: .utf8)!
//				rvString.append(string)
				rvData = data!
//			} catch {
//				print("could not jsonify")
//			}
		}
	}
	
	let task = session.session.dataTask(with: dataURL, completionHandler: handler)  // loads data into memory
	task.resume()
		
	while rvData == nil {
		sleep(1)
	}
	
	return rvData!
}

let rvData = getLatestData(dataURL: dataURL)
let rvDataString: String = String(data: rvData!, encoding: .utf8)!

let dataLines: [String] = rvDataString.components(separatedBy: "\n")
print(dataLines[0])

let dataKeys: [String] = dataLines[0].components(separatedBy: ",")
print(dataKeys)

struct DataEntry: Codable {
	
	var FIPS: String
	var Admin2: String
	var Province_State: String
	var Country_Region: String
	var Last_Update: String
	var Lat: String
	var Long_: String
	var Confirmed: String
	var Deaths: String
	var Recovered: String
	var Active: String
	var Combined_Key: String
	var Incident_Rate: String
	var Case_Fatality_Ratio: String
	
	init(dict: Dictionary<String, String>) {
		FIPS = dict["FIPS"] ?? ""
		Admin2 = dict["Admin2"] ?? ""
		Province_State = dict["Province_State"] ?? ""
		Country_Region = dict["Country_Region"] ?? ""
		Last_Update = dict["Last_Update"] ?? ""
		Lat = dict["Lat"] ?? ""
		Long_ = dict["Long_"] ?? ""
		Confirmed = dict["Confirmed"] ?? ""
		Deaths = dict["Deaths"] ?? ""
		Recovered = dict["Recovered"] ?? ""
		Active = dict["Active"] ?? ""
		Combined_Key = dict["Combined_Key"] ?? ""
		Incident_Rate = dict["Incident_Rate"] ?? ""
		Case_Fatality_Ratio = dict["Case_Fatality_Ratio"] ?? ""
	}
	
	
}


var dataEntries: [DataEntry] = []
for line in dataLines[1...] {
	let tdict: [String:String] = Dictionary(uniqueKeysWithValues: zip(dataKeys, line.components(separatedBy: ",")))
	dataEntries.append(DataEntry(dict: tdict))
	
//	let e = try JSONDecoder().decode([DataEntry].self, from: tdict_encoded)
//	dataEntries.append(contentsOf: e)
}
print(dataEntries[0])

