//
//  ViewController.swift
//  COVIDTracker
//
//  Created by Mark on 12/11/20.
//

import UIKit
import COVIDData
import Charts

class ChartConfig {
	// Holds the current state of a chart
	var chart: BarChartView
	var color: UIColor
	
	init(chart: BarChartView, color: UIColor) {
		
		// setup the common chart configuration elements
		self.chart = chart
		self.color = color
		
		self.chart.backgroundColor = .white
		
		// disable right axis
		self.chart.rightAxis.enabled = false
		
		// format left axis
		self.chart.leftAxis.labelTextColor = .black
		self.chart.leftAxis.setLabelCount(10, force: false)
		self.chart.xAxis.labelPosition = .bottom
		self.chart.xAxis.labelTextColor = .black
		
		// remove grid
		self.chart.drawGridBackgroundEnabled = false
		self.chart.xAxis.drawGridLinesEnabled = false
		self.chart.leftAxis.drawGridLinesEnabled = false
		
		// animate
		self.chart.animate(yAxisDuration: 0.5)
	}
	
	func update(withData data: Data) {
		// updates chart with data
		let dates: [Date]
		let values: [Int32]
		
		switch (data.currentFrequency, data.currentDataType) {
			case (.cumulative, .confirmed):
				dates = data.cases!.dates
				values = data.cases!.cumulativeValues
			case (.cumulative, .deaths):
				dates = data.deaths!.dates
				values = data.deaths!.cumulativeValues
			case (.daily, .confirmed):
				dates = data.cases!.dates
				values = data.cases!.dailyValues
			case (.daily, .deaths):
				dates = data.deaths!.dates
				values = data.deaths!.dailyValues
		}
		
		var entries = [ChartDataEntry]()
		for (i, (_, v)) in zip(dates, values).enumerated() {
			entries.append(BarChartDataEntry(x: Double(i), y: Double(v)))
		}
		let dataSet = BarChartDataSet(entries: entries, label: "\(data.filter ?? "") \(data.currentDataType.proper())")
		dataSet.setColor(color)
		dataSet.highlightColor = .blue
		
		chart.data = BarChartData(dataSet: dataSet)
//		let desc = Description()
//		desc.text = "\(data.filter ?? "") \(data.currentDataType.proper())"
//		desc.textAlign = NSTextAlignment.left
//		desc.position = CGPoint(x: 70, y: 10)
//		desc.font = NSUIFont(name: "Helvetica", size: CGFloat(18))!
		
//		chart.chartDescription = desc
		chart.animate(yAxisDuration: 0.5)
		
		chart.setNeedsDisplay()
		
	}
	
}

class DataDisplayConfig {
	// Holds the data display elements
	var casesTextLabel: UILabel?
	var casesDataLabel: UILabel?
	var deathsTextLabel:UILabel?
	var deathsDataLabel: UILabel?
	
	init(casesTextLabel: UILabel? = nil,
		 casesDataLabel: UILabel? = nil,
		 deathsTextLabel:UILabel? = nil,
		 deathsDataLabel: UILabel? = nil) {
									self.casesTextLabel = casesTextLabel
									self.casesDataLabel = casesDataLabel
									self.deathsTextLabel = deathsTextLabel
									self.deathsDataLabel = deathsDataLabel
	}
	
	func update(withData data: Data) {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = 0
		formatter.numberStyle = .decimal
		
		// update the data display based on the Data object values
		var casesData: [Int32]?
		var deathsData: [Int32]?
		if let t = casesTextLabel, let d = casesDataLabel {
			t.text = "\(data.currentFrequency.rawValue) Cases"
			switch data.currentFrequency {
				case .cumulative:
					casesData = data.cases!.cumulativeValues
				case .daily:
					casesData = data.cases!.dailyValues
			}
			d.text = formatter.string(from: NSNumber(value: casesData![casesData!.count-1]))!
		}
		if let t = deathsTextLabel, let d = deathsDataLabel {
			t.text = "\(data.currentFrequency.rawValue) Deaths"
			switch data.currentFrequency {
				case .cumulative:
					deathsData = data.deaths!.cumulativeValues
				case .daily:
					deathsData = data.deaths!.dailyValues
			}
			d.text = formatter.string(from: NSNumber(value: deathsData![deathsData!.count-1]))!
		}
	}
}

class Data {
	// Holds the data elements for a scope and the current data state
	var scope: Scope
	var filter: String?
	var levelOfDetail: LevelOfDetail
	var cases: (areas:[String], dates:[Date], dailyValues:[Int32], cumulativeValues: [Int32])?
	var deaths: (areas:[String], dates:[Date], dailyValues:[Int32], cumulativeValues: [Int32])?
	var currentDataType: DataType
	var currentFrequency: Frequency
	
	init (scope s:Scope, levelOfDetail l: LevelOfDetail = .top, filter f: String? = nil) {
		self.scope = s
		self.currentDataType = .confirmed
		self.currentFrequency = .cumulative
		self.filter = f
		self.levelOfDetail = l
		
		// Load data for cases and deaths
		let casesCD = COVIDData(scope: s, dataType: .confirmed)
		self.cases = casesCD.data(levelOfDetail: self.levelOfDetail, dateRange: .all, filter: self.filter)!
		
		let deathsCD = COVIDData(scope: s, dataType: .deaths)
		self.deaths = deathsCD.data(levelOfDetail: self.levelOfDetail, dateRange: .all, filter: self.filter)!
	
	}
	
	func toggleFrequency(chartConfig c: [ChartConfig], displayConfig d: DataDisplayConfig) {
		switch self.currentFrequency {
			case .cumulative:
				self.currentFrequency = .daily
			case .daily:
				self.currentFrequency = .cumulative
		}
		
		c.forEach({chart in chart.update(withData: self)})
		d.update(withData: self)
	}
	
	func setDataType(dataType d: DataType, chartConfig c: ChartConfig) {
		// if type wasn't changed don't do anything
		if d == currentDataType { return }
		switch d {
			case .confirmed:
				self.currentDataType = .confirmed
			case .deaths:
				self.currentDataType = .deaths
		}
		c.update(withData: self)
	}
	
}

class ViewController: UIViewController, ChartViewDelegate {

	@IBOutlet weak var globalCasesDataLabel: UILabel!
	@IBOutlet weak var globalCasesTextLabel: UILabel!
	@IBOutlet weak var globalDeathsDataLabel: UILabel!
	@IBOutlet weak var globalDeathsTextLabel: UILabel!
	@IBOutlet weak var usCasesDataLabel: UILabel!
	@IBOutlet weak var usCasesTextLabel: UILabel!
	@IBOutlet weak var usDeathsDataLabel: UILabel!
	@IBOutlet weak var usDeathsTextLabel: UILabel!
	@IBOutlet weak var globalChart: BarChartView!
	@IBOutlet weak var usChart: BarChartView!
	// These are used as buttons to toggle chart between Confirmed and Deaths
	@IBOutlet weak var globalDataStack: UIStackView!
	@IBOutlet weak var globalCasesStack: UIStackView!
	@IBOutlet weak var globalDeathStack: UIStackView!
	@IBOutlet weak var usDataStack: UIStackView!
	@IBOutlet weak var usCasesStack: UIStackView!
	@IBOutlet weak var usDeathStack: UIStackView!
	
	var globalChartConfig: ChartConfig?
	var globalDataDisplayConfig: DataDisplayConfig?
	var globalData: Data?
	
	var usChartConfig: ChartConfig?
	var usDataDisplayConfig: DataDisplayConfig?
	var usData: Data?
	
	@objc func updateChartDataType(_ sender: UIStackView) {
		// Called by touch events for each data stack
		switch sender.value(forKey: "view")! as! UIStackView {
			case globalCasesStack:
				globalData!.setDataType(dataType: .confirmed, chartConfig: globalChartConfig!)
			case globalDeathStack:
				globalData!.setDataType(dataType: .deaths, chartConfig: globalChartConfig!)
			case usCasesStack:
				usData!.setDataType(dataType: .confirmed, chartConfig: usChartConfig!)
			case usDeathStack:
				usData!.setDataType(dataType: .deaths, chartConfig: usChartConfig!)
			default:
				break
		}
	}
	
	@objc func updateChartFrequency(_ sender: BarChartView) {
		// Called by touch events for each chart
		switch sender.value(forKey: "view")! as! BarChartView {
		case globalChart:
			globalData!.toggleFrequency(chartConfig: [globalChartConfig!], displayConfig: globalDataDisplayConfig!)
		case usChart:
			usData!.toggleFrequency(chartConfig: [usChartConfig!], displayConfig: usDataDisplayConfig!)
		default:
			break
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		globalChartConfig = ChartConfig(chart: globalChart,
										color: .orange)
		
		globalDataDisplayConfig = DataDisplayConfig(
			casesTextLabel: globalCasesTextLabel,
			casesDataLabel: globalCasesDataLabel,
			deathsTextLabel: globalDeathsTextLabel,
			deathsDataLabel: globalDeathsDataLabel
		)
		
		globalData = Data(scope: .global)
		
		globalChartConfig!.update(withData: globalData!)
		globalDataDisplayConfig!.update(withData: globalData!)
		
		usChartConfig = ChartConfig(chart: usChart,
									color: .blue)
		
		usDataDisplayConfig = DataDisplayConfig(
			casesTextLabel: usCasesTextLabel,
			casesDataLabel: usCasesDataLabel,
			deathsTextLabel: usDeathsTextLabel,
			deathsDataLabel: usDeathsDataLabel
		)
		
		usData = Data(scope: .us)
		
		usChartConfig!.update(withData: usData!)
		usDataDisplayConfig!.update(withData: usData!)
		
		// Setup data stack items to update chart's datatype when touched
		let stacks = [globalCasesStack!, globalDeathStack!, usCasesStack!, usDeathStack!]
		stacks.forEach { stack in
							let touchElem = UITapGestureRecognizer(target: self, action:  #selector (updateChartDataType))
							stack.addGestureRecognizer(touchElem)
						}
		
		// Setup the charts tp update the frequency when touched
		let charts = [globalChart!, usChart!]
		charts.forEach { chart in
			let touchElem = UITapGestureRecognizer(target: self, action:  #selector (updateChartFrequency))
			chart.addGestureRecognizer(touchElem)
		}
		
	}

}

