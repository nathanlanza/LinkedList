import XCTest
@testable import LinkedList

class LinkedListTests: XCTestCase {
    
    func test_Equality_ReturnsTrueWhenEqual() {
        let ll: LinkedList = [1,2,3,4,5]
        let result = ll == ll
        XCTAssert(result == true)
    }
    
    func test_Equality_ReturnsFalseWhenNotEqual() {
        let ll: LinkedList = [1,2,3,4,5]
        let ll2: LinkedList = [5,4,3,2,1]
        let result = ll == ll2
        XCTAssert(result == false)
    }
    
    func test_Equality_ReturnsFalseWhenDifferentCounts() {
        let ll: LinkedList = [1,2,3,4,5]
        let ll2: LinkedList = [1,2,3,4,5,6]
        let result = ll == ll2
        XCTAssert(result == false)
    }

    
}
