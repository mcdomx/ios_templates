import XCTest
@testable import CoreDataCOVID

final class CoreDataCOVIDTests: XCTestCase {
    
	func testCoreData() {
		let d = Bundle.module.url(forResource: "COVIDData", withExtension: "xcdatamodeld")
		XCTAssertNotNil(d)
	}

    static var allTests = [
        ("testCoreData", testCoreData),
    ]
}
