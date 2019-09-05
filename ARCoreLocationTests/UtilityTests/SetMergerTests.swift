//
//  SetMergerTests.swift
//  ARCoreLocationTests
//
//  Created by Skyler Smith on 2018-09-24.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import XCTest
@testable import ARCoreLocation

class SetMergerTests: XCTestCase {
    
    func testMergesCommonElements1() {
        // Given
        let group1 = Set([Set([1,2]), Set([2,3]), Set([4,5]), Set([1,2]), Set([4,6])])
        let group2 = Set([Set(["1","2"]), Set(["3","4"]), Set(["5","6"]), Set(["2","3"]), Set(["6","1"])])
        let group3 = Set([Set([1,2,3,4,5,6]), Set([1,3,5,7,9,11])])
        let group4 = Set([Set([1])])
        let group5 = Set([Set([1,2,4]), Set([3,5,7]), Set([6,8]), Set([0]), Set([2,8]), Set([7,9,11,13])])
        let group6 = Set([Set([1,2]), Set([4,5]), Set([5,6]), Set([7,8]), Set([8,9]), Set([8,10]), Set([9,10])])
        
        // When
        let merged1 = SetMerger.mergeByCommonElements(sets: group1)
        let merged2 = SetMerger.mergeByCommonElements(sets: group2)
        let merged3 = SetMerger.mergeByCommonElements(sets: group3)
        let merged4 = SetMerger.mergeByCommonElements(sets: group4)
        let merged5 = SetMerger.mergeByCommonElements(sets: group5)
        let merged6 = SetMerger.mergeByCommonElements(sets: group6)
        
        // Then
        XCTAssertEqual(merged1, Set([Set([1,2,3]), Set([4,5,6])]))
        XCTAssertEqual(merged2, Set([Set(["1", "2", "3", "4", "5", "6"])]))
        XCTAssertEqual(merged3, Set([Set([1,2,3,4,5,6,7,9,11])]))
        XCTAssertEqual(merged4, Set([Set([1])]))
        XCTAssertEqual(merged5, Set([Set([0]), Set([1,2,4,6,8]), Set([3,5,7,9,11,13])]))
        XCTAssertEqual(merged6, Set([Set([1,2]), Set([4,5,6]), Set([7,8,9,10])]))
    }
    
    func testMergesCommonElements2() {
        // Given
        let group = Set([Set([7,10]), Set([25,13,19]), Set([10,13]), Set([1,2]), Set([15,2])])
        
        // When
        let merged = SetMerger.mergeByCommonElements(sets: group)
        
        // Then
        XCTAssertEqual(merged, Set([Set([7,10,13,25,19]), Set([1,2,15])]), "The set was not merged correctly!")
    }

}
