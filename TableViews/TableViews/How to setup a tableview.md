#  How to Setup a Table View
This how-to comes from the following LinkedIn learning videos:
https://www.linkedin.com/learning/ios-13-development-essential-training-1-fundamentals-ui-and-architecture/table-view-controllers

## Setup a TableView Controller
First, create a new swift file with template code for a tableview
1.  Start with a basic project
2.  Select the `ViewController.swift` file and highlight the `UIViewController` type.
3.  With the ViewController selected, click CMD-N to create a new file.
4.  Choose "Cocoa Touch Class"
5.  Subclass: `UITableViewController`.  The default class name `TableViewController` is acceptable. 
	No XIB file. Language: Swift.
6.  Save the file at the default location.


## Create a Scene for the TableView
Next, create a scene for the table view and connect it to the swift file we created in the previous section.  In this example, we make the tableview the first element in the application.
7.  Select the  main storyboard.   
8.  Use the '+' button to add a new `TableViewController`.  Drag it to a blank space on the storyboard.
9. Connect the new scene to the `TableViewController` class by selecting the icon on the far left that represents class which the storyboard object is connected to.  
10. In the inspector pane, select 'Initial View Controller'.  This will move the entry arrow to the new `TableViewController` and makes the tableview the first element that is seen when starting the application.
11. Connect the scene to the respective class by selecting the class pane and identifying `TableViewController` in the class field.
12. At this point, we have connected the scene to the controlling class and set the scene as the initial entry point into the application.

## Link Data to the TableView Cells
Load data into the tableview rows.
13. Each row of the table is referred to as a tableview cell.
14. Go to `TableViewController` scene and select the topmost whitespace in the tableview controller which represents the prototype tableview cell. 
15. Go to the attributes pane and enter "cell" in the Identifier field.  This creates a code-accessible variable for the cells in the table.
16. Go the the swift code of the `TableViewController` class.
17. Define the data that will be displayed in the table using a class-wide variable.  This will most likely be an NSArray.

	let items: [String] = ["Item1", "Item2", "Item3", ...]
	
18. Using code, the number of rows and sections is defined in the following template functions:

example:
	
	numberOfSections() {
		return 1
	}
	tableView(... numberOfRowsInSection) {
		return data.count 
	}
	
19. Uncomment the function `tableView(... cellForRowAt: ...)` and change the "ResuseIdentifier" to "cell" (as defined in step 15).
20. In that function, you will define what goes in each cell.

example:

	cell.textLabel?.text = data[indexPath.row]
	
The indexPath holds the .section and .row data.  Section will be "indexPath.section".
	
## Create a NavigationController
Now, we will create a NavigationController that will let us move to a new screen when an item is selected.  This is the section at the top that allows you to go back as well as add new items.
21. In the storyboard, select the `TableViewController` from the element listing and select 'Editor>Embed In>Navigation Controller'.
22. Now add large title bar to the newly-created navigation controller.  Select the 'Navigation Bar' from the element's element list. Show the attributes inspector and select 'Prefers Large Titles'.
23. Then, select the `TableViewController` and select the 'Navigation Item' from the listing and give the title a name in the 'Title' field in the inspector.  This is the header that will be used for the table.  Here, you can also add a custom back button text but since this example uses the table view as the first scene in the application, this wouldn't make sense.
24. After these steps are complete, the navigation bar is embedded in the table view with a large font.

## Transition to New Scene When Table Item is Selected
In this step, we will setup a new scene that is displayed when an item in the table is selected.  To do this, we need to setup a new `ViewController` that represents the new scene and point the `TableViewController` to this new scene.
25. We should still have the default application's `ViewController` storyboard element which we can use as the desintation scene.  If it is not there, add a new `ViewController`.
26. To connect the `TableViewController` to the new `ViewController`, from the `TableViewController`, drag the class icon to the new `ViewController` storyboard element.  When prompted, select  'Show' segue.  This sets up the transition from one storyboard element to another.
27. The segue is represented by the line between the two storyboard elements.  Select that seque line and give it an identifier: "showDetail".  This gives you a name that can be accessed in code that represents the segue.
28. We must also give the `ViewController`'s Navigation Item a title in the Title field: "item".  This provides a value that can be accessed in code.
29. Now, we need to create the code that supports the transition.  Go to the `TableViewController.swift` code file.
30. Uncomment the function the Navigation section at the bottom of the file. `prepare()`
31. Create a new method that will be executed when an item is selected in the tableviewcontroller.

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		currentItem = data[indexPath.row]
		performSegue(withIdentifier: "showDetail", sender: nil)
	}
	
The first line of the fuction is discussed in step 35.  This function is called every time a new item is selected in the table.
	
32. In the `prepare()` function that was uncommented in step 30, we can send data from the TableViewController to the seque's destination.  To do this, we use "seque.destination", but first, we need to setup a variable in the destination controller that will recieve the value/s.
33. In the ViewController, create a new class variable for the text
		`var text: String = ""`
34. In the TableViewController, create a class variable:
		`var currentItem: String = ""`
35. In the function from step 31 (`tableView(didSelect...)`), create a new line above performSeque:
		`currentItem = data[indexPath.row]`
	This will assign the currentItem value to whatever is clicked.
36.  In the `prepare()` function, we will assign this currentValue to the designation's new variable:

	if let viewController = seque.destinaton as? ViewController {
		viewController.text = currentItem
	}
	
37. The very last step is to display the data we saved to 'text' in the storyboard element.
38. Create a text element in the `ViewController` storyboard element.
39. Use the assistant editor to connect the storyboard textview to a new IBOutlet variable in the swift code for the `ViewController`:
	
	`@IBOutlet weak var navItem: UINavigationItem!`
	
40. In viewDidLoad, update the `viewDidLoad()` function:

	`override func viewDidLoad() {
		super.viewDidLoad()
		navItem.title = item
	}`

	This will update the text when the board item is first loaded
	
41. Add a new function:

	`override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navItem.title = item
	}`
	
	This will update the item after the first load and subsequent views.
	
	
	
	
	
	
