/*:

# Counter
This application will demonsrate the a charting library.  The application will capture a tally by the user where the tally count is incremented or decremented by 1 at each ress.  A bar chart will show the tally total at each button press.

## References

---
#### Charts

This application relies on a 3rd party framework called `Charts` and can be found on github:

[https://github.com/danielgindi/Charts](https://github.com/danielgindi/Charts)

Note that `Charts` will need to be loaded using Cocoapods via the command line.

---

#### TinyConstraints

Additionally, the project uses athe following libary to help with layout contraints:

[https://github.com/roberthein/TinyConstraints](https://github.com/roberthein/TinyConstraints)

Note that `TinyConstraints` can be loaded using  `Swift Packages` from the XCode interface.

---
#### YouTube Tutorial

I followed the YouTube video linked below to show how it was implemented:

[https://www.youtube.com/watch?v=mWhwe_tLNE8](https://www.youtube.com/watch?v=mWhwe_tLNE8)


## Chart Setup Steps
---
Each chart has a few set of necessary items that are similar across chart types:

#### 1. Imports
First, make sure to import Charts and TinyConstraints

	import Charts
	import TinyConstraints

#### 2. Chart Object
This is the UIView that will be displayed.  Elements of the overall chart can be configured.
	
	let chartView = LineChartView()
	chartView.backgroundColor = .systemBlue
	chartView.rightAxis.enabled = false
	chartView.rightAxis.labelTextColor = .white
	chartView.xAxis.labelPosition = .bottom
	chartView.animate(yAxisDuration: 1.0)


#### 3. Configure the DataSet
Chart data is in a `DataSet`.  This data series includes attributes that describe on how that dataset is formatted in the chart.

	let set1 = LineChartDataSet()
	set1.label = "line chart data"
	set1.drawCirclesEnabled = false
	set1.lineWidth = 3
	
	// round the corners on the charted line
	set1.mode = .cubicBezier

	// fill the area
	set1.fill = Fill(color: .white)
	set1.fillAlpha = 0.6
	set1.drawFilledEnabled = true

	// chanage cross-hairs
	set1.drawVerticalHighlightIndicatorEnabled = false
	set1.highlightColor = .systemPink

#### 4. Create DataSet Entries
Each element in the `DataSet` is a `DataSetEntry` which includes the coordinates of each point.

	entry1 = LineChartDataEntry(x: 0.0, y: 10.1)
	entry2 = LineChartDataEntry(x: 0.0, y: 13.1)
	let dataEntries: [LineChartDataEntry] = [entry1, entry 2]
	set1.append(contentsOf: dataEntries)

#### 5. Assign DataSet to the Chart
Finally, the `DataSet` is assigned to the chart's `data` attribute.

	let data = LineChartData(dataSet: set1)
	chartView.data = data

#### 6. Change Displayed Data
If the `data` attribute is changed, the chart must be notified that it should be redrawn:

	chartView.data!.addEntry(newEntry, dataSetIndex: 0)
	chartView.notifyDataSetChanged()

*/
