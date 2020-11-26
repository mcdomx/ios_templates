//
//  ViewController.swift
//  volumeButtonInput
//
//  Created by Mark on 11/24/20.
//

import UIKit
import Charts
import TinyConstraints


class ViewController: UIViewController, ChartViewDelegate {
	
	@IBOutlet weak var countValue: UILabel!
	@IBAction func decrButton(_ sender: Any) {
		if tally > 0 {
			tally -= 1
			count += 1
			countValue.text = "\(tally)"
			updateChartData(chart: self.chartView, value: Double(tally))
		}
	}
	@IBAction func incrButton(_ sender: Any) {
		tally += 1
		count += 1
		countValue.text = "\(tally)"
		updateChartData(chart: self.chartView, value: Double(tally))
	}
	
	var count: Int = 0
	var tally: Int = 0
	var chartView = BarLineChartViewBase()
	
	func setChartType(type: String) {
		if type == "line" {
			chartView = lineChartView
		} else if type == "bar" {
			chartView = barChartView
		} else {
			print ("Type not supported: \(type)")
		}
		
	}
	
	lazy var lineChartView: LineChartView = {
		let chartView = LineChartView()
		chartView.backgroundColor = .systemBlue
		
		// disable right axis
		chartView.rightAxis.enabled = false
		chartView.rightAxis.labelTextColor = .white
		chartView.leftAxis.setLabelCount(10, force: false)
		chartView.xAxis.labelPosition = .bottom
		chartView.xAxis.labelTextColor = .white
		
		// animate
		chartView.animate(yAxisDuration: 1.0)
		
		// initialize data
		let set1 = LineChartDataSet()
		set1.label = "line chart data"
		set1.drawCirclesEnabled = false
		set1.lineWidth = 3
		set1.setColor(.white)
		
		// round the corners on the charted line
		set1.mode = .cubicBezier
		
		// fill the area
		set1.fill = Fill(color: .white)
		set1.fillAlpha = 0.6
		set1.drawFilledEnabled = true
		
		// chanage cross-hairs
		set1.drawVerticalHighlightIndicatorEnabled = false
		set1.highlightColor = .systemPink
		
		set1.append(contentsOf: <#T##Sequence#>)
		
		let data = LineChartData(dataSet: set1)
		data.setDrawValues(false)
		chartView.data = data
		
		return chartView
	}()
	
	lazy var barChartView: BarChartView = {
		let chartView = BarChartView()
		chartView.backgroundColor = .systemBlue
		
		// disable right axis
		chartView.rightAxis.enabled = false
		chartView.rightAxis.labelTextColor = .white
		chartView.leftAxis.setLabelCount(10, force: false)
		chartView.xAxis.labelPosition = .bottom
		chartView.xAxis.labelTextColor = .white
		
		// animate
		chartView.animate(yAxisDuration: 1.0)
		
		// initialize data
		let set1 = BarChartDataSet()
		set1.label = "bar chart data"
		set1.setColor(.white)
		set1.highlightColor = .systemPink
		let data = BarChartData(dataSet: set1)
		data.setDrawValues(false)
		chartView.data = data
		
		return chartView
	}()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		countValue.text = "\(count)"
		
		setChartType(type: "bar")
		
		// add to parent 'view' and set constraints
		view.addSubview(chartView)
		chartView.centerXToSuperview()
		chartView.top(to: view.safeAreaLayoutGuide)
		chartView.width(to: view)
		chartView.heightToWidth(of: view)
		
	}
	
	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		print(entry)
	}
	
	func updateChartData(chart: BarLineChartViewBase, value: Double) {
		// add value to the chart data and redraw the chart
		let newIndex = chart.data!.dataSets[0].entryCount
		
		var entry = ChartDataEntry()
		
		if ((chart as? BarChartView) != nil) {
			entry = BarChartDataEntry(x: Double(newIndex), y: value)
		} else if ((chart as? LineChartView) != nil) {
			entry = ChartDataEntry(x: Double(newIndex), y: value)
		} else {
			print("chart type not supported")
			return
		}
		
		// update the chart's data and notify the chart to update
		chart.data!.addEntry(entry, dataSetIndex: 0)
		chart.notifyDataSetChanged()
		
		// only show the last 10 changes - older items are scrollable
		if newIndex > 10 {
			chart.setVisibleXRangeMaximum(10.0)
			chart.moveViewToX(Double(newIndex-10+1))
		}
		
	}
	

}

