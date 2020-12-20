//
//  SelectedCountryViewController.swift
//  COVIDTracker
//
//  Created by Mark on 12/17/20.
//

import UIKit
import COVIDData
import Charts

class SelectedCountryViewController: UIViewController, ChartViewDelegate {
	
	@IBOutlet weak var navItem: UINavigationItem!
	@IBOutlet weak var casesTextLabel: UILabel!
	@IBOutlet weak var casesDataLabel: UILabel!
	@IBOutlet weak var deathsTextLabel: UILabel!
	@IBOutlet weak var deathsDataLabel: UILabel!
	
	// Charts are also used as buttons to toggle frequency
	@IBOutlet weak var casesChart: BarChartView!
	@IBOutlet weak var deathsChart: BarChartView!

	var country: String = ""
	
	var casesStateCumulative = false
	var deathsStateCumulative = false
	
	var casesChartConfig: ChartConfig?
	var casesDataDisplayConfig: DataDisplayConfig?
	var casesData: Data?
	var deathsChartConfig: ChartConfig?
	var deathsDataDisplayConfig: DataDisplayConfig?
	var deathsData: Data?
	
	@objc func updateChartFrequency(_ sender: BarChartView) {
		// Called by touch events for each chart
		switch sender.value(forKey: "view")! as! BarChartView {
		case casesChart:
			casesData!.toggleFrequency(chartConfig: [casesChartConfig!], displayConfig: casesDataDisplayConfig!)
		case deathsChart:
			deathsData!.toggleFrequency(chartConfig: [deathsChartConfig!], displayConfig: deathsDataDisplayConfig!)
		default:
			break
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		navItem.title = country
		
		casesChartConfig = ChartConfig(chart: casesChart, color: .orange)
		casesDataDisplayConfig = DataDisplayConfig(
			casesTextLabel: casesTextLabel,
			casesDataLabel: casesDataLabel)
		casesData = Data(scope: .global, levelOfDetail: .country, filter: country)
		casesData!.setDataType(dataType: .confirmed, chartConfig: casesChartConfig!)
		casesChartConfig!.update(withData: casesData!)
		casesDataDisplayConfig?.update(withData: casesData!)
		
		deathsChartConfig = ChartConfig(chart: deathsChart, color: .blue)
		deathsDataDisplayConfig = DataDisplayConfig(
			deathsTextLabel: deathsTextLabel,
			deathsDataLabel: deathsDataLabel)
		deathsData = Data(scope: .global, levelOfDetail: .country, filter: country)
		deathsData!.setDataType(dataType: .deaths, chartConfig: deathsChartConfig!)
		deathsChartConfig!.update(withData: deathsData!)
		deathsDataDisplayConfig!.update(withData: deathsData!)
		
		
		
		// Setup the charts tp update the frequency when touched
		let charts = [casesChart!, deathsChart!]
		charts.forEach { chart in
			let touchElem = UITapGestureRecognizer(target: self, action:  #selector (updateChartFrequency))
			chart.addGestureRecognizer(touchElem)
		}
    }
}
