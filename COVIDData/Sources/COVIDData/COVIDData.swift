import Foundation
import SwiftCSV

public enum Scope: String {
	case us = "US"
	case global = "global"
}

public enum DataType: String {
	case deaths = "deaths"
	case confirmed = "confirmed"
}


struct DataURL {
// Provides the correct URL for a supplied scope and datatype
	let scope: Scope
	let dataType: DataType
	var URL: NSURL
	let url = {
		(s: Scope, d: DataType) in
		return ("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_\(d.rawValue)_\(s.rawValue).csv")
	}
	
	init(_ s:Scope, _ d:DataType) {
		self.scope = s
		self.dataType = d

		self.URL = NSURL(string: url(s, d))!

	}
		
	
}

public class COVIDData {
	// Primary type for accessing Data
	// Requires initialization with appropriate scope and data type
	
	var scope: Scope
	var dataType: DataType
	var text: String
	var URL: NSURL {
		get { return  DataURL(scope, dataType).URL }
	}
	
	public init() {
		// Seconday init approach if no scope or datatype is supplied
		self.scope = Scope.us
		self.dataType = DataType.confirmed
		self.text = "Scope: \(self.scope) DataType: \(self.dataType)"
	}
	
	public init(scope: Scope, dataType: DataType) {
		// preferred initialization approach
		self.scope = scope
		self.dataType = dataType
		self.text = "Scope: \(self.scope) DataType: \(self.dataType)"
	}
	
	public func getCSV() -> [[String:String]] {
		
		do {
			let csv:CSV = try CSV(url: self.URL as URL)
			return csv.namedRows
		} catch {
			print(error)
			return [[:]]
		}
		
	}
	
}
