//
//  InteractiveSceneTests.swift
//  ARCoreLocationTests
//
//  Created by Skyler Smith on 2018-09-24.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import XCTest
import SpriteKit
@testable import ARCoreLocation

class InteractiveSceneTests: XCTestCase {

    var scene: InteractiveScene!
    var delegate: MockInteractionDelegate!
    
    override func setUp() {
        super.setUp()
        scene = InteractiveScene()
        delegate = MockInteractionDelegate()
        scene.interactionDelegate = delegate
    }

    override func tearDown() {
        scene = nil
        delegate = nil
        super.tearDown()
    }

    func testIntersections() {
        // Given
        let node1 = SKSpriteNode(color: .black, size: CGSize(width: 10, height: 10))
        node1.position = CGPoint(x: 0, y: 0)
        let node2 = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 10))
        node2.position = CGPoint(x: 5, y: 5)
        
        scene.addChild(node1)
        scene.addChild(node2)
        
        // When
        let (intersections, independents) = scene.intersectingNodes(searchGeneration: 0)
        
        // Then
        XCTAssertTrue(intersections.contains(where: { (nodeSet) -> Bool in
            return nodeSet.contains(node1) && nodeSet.contains(node2)
        }))
        XCTAssertTrue(independents.isEmpty)
    }
    
    func testIntersections2() {
        // Given
        let node1 = SKSpriteNode(color: .black, size: CGSize(width: 12, height: 12))
        node1.position = CGPoint(x: 6, y: 6)
        let node2 = SKSpriteNode(color: .black, size: CGSize(width: 5, height: 5))
        node2.position = CGPoint(x: 20, y: 20)
        let node3 = SKSpriteNode(color: .white, size: CGSize(width: 34, height: 34))
        node3.position = CGPoint(x: -10, y: -5)
        
        scene.addChild(node1)
        scene.addChild(node2)
        scene.addChild(node3)
        
        // When
        let (intersections, independents) = scene.intersectingNodes(searchGeneration: 0)
        
        // Then
        XCTAssertTrue(intersections.contains(where: { (nodeSet) -> Bool in
            return nodeSet.contains(node1) && nodeSet.contains(node3)
        }))
        XCTAssertEqual(independents.count, 1)
        XCTAssertTrue(independents.contains(node2))
    }
    
    func testNoIntersections() {
        // Given
        let node1 = SKSpriteNode(color: .black, size: CGSize(width: 10, height: 10))
        node1.position = CGPoint(x: 0, y: 0)
        let node2 = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 10))
        node2.position = CGPoint(x: 15, y: 0)
        
        scene.addChild(node1)
        scene.addChild(node2)
        
        // When
        let (intersections, independents) = scene.intersectingNodes(searchGeneration: 0)
        
        // Then
        XCTAssertTrue(intersections.isEmpty)
        XCTAssertTrue(independents.contains(node1))
        XCTAssertTrue(independents.contains(node2))
    }
    
    func testIntersectionsAndIndependents() {
        // Given
        let node1 = SKSpriteNode(color: .black, size: CGSize(width: 10, height: 10))
        node1.position = CGPoint(x: 0, y: 0)
        let node2 = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 10))
        node2.position = CGPoint(x: 13, y: 0)
        let node3 = SKSpriteNode(color: .red, size: CGSize(width: 10, height: 10))
        node3.position = CGPoint(x: 100, y: 100)
        let node4 = SKSpriteNode(color: .green, size: CGSize(width: 10, height: 10))
        node4.position = CGPoint(x: 9, y: 0)
        
        scene.addChild(node1)
        scene.addChild(node2)
        scene.addChild(node3)
        scene.addChild(node4)
        
        // When
        let (intersections, independents) = scene.intersectingNodes(searchGeneration: 0)
        
        // Then
        XCTAssertTrue(intersections.contains(where: { (nodeSet) -> Bool in
            return nodeSet.contains(node1) && nodeSet.contains(node2) && nodeSet.contains(node4)
        }))
        XCTAssertEqual(intersections.count, 1)
        XCTAssertTrue(independents.contains(node3))
        XCTAssertEqual(independents.count, 1)
    }
    
    func testMultipleIntersectionsAndGrandchildren() {
        // Given
        let node1 = SKSpriteNode(color: .black, size: CGSize(width: 10, height: 10))
        let parent1 = SKSpriteNode(color: .black, size: CGSize(width: 0, height: 0))
        parent1.position = CGPoint(x: 0, y: 0)
        parent1.addChild(node1)
        let node2 = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 10))
        let parent2 = SKSpriteNode(color: .white, size: CGSize(width: 0, height: 0))
        parent2.position = CGPoint(x: 13, y: 0)
        parent2.addChild(node2)
        let node3 = SKSpriteNode(color: .red, size: CGSize(width: 10, height: 10))
        let parent3 = SKSpriteNode(color: .red, size: CGSize(width: 0, height: 0))
        parent3.position = CGPoint(x: 100, y: 100)
        parent3.addChild(node3)
        let node4 = SKSpriteNode(color: .green, size: CGSize(width: 10, height: 10))
        let parent4 = SKSpriteNode(color: .green, size: CGSize(width: 0, height: 0))
        parent4.position = CGPoint(x: 9, y: 0)
        parent4.addChild(node4)
        let node5 = SKSpriteNode(color: .orange, size: CGSize(width: 10, height: 10))
        let parent5 = SKSpriteNode(color: .orange, size: CGSize(width: 0, height: 0))
        parent5.position = CGPoint(x: 101, y: 100)
        parent5.addChild(node5)
        
        scene.addChild(parent1)
        scene.addChild(parent2)
        scene.addChild(parent3)
        scene.addChild(parent4)
        scene.addChild(parent5)
        
        // When
        let (intersections1, independents1) = scene.intersectingNodes(searchGeneration: 0)
        
        let (intersections2, independents2) = scene.intersectingNodes(searchGeneration: 1)
        
        // Then
        XCTAssertTrue(intersections1.isEmpty) // None of the parents are touching
        XCTAssertEqual(independents1.count, 5)
        
        XCTAssertTrue(intersections2.contains(where: { (nodeSet) -> Bool in
            return nodeSet.contains(node1) && nodeSet.contains(node2) && nodeSet.contains(node4)
        }))
        XCTAssertTrue(intersections2.contains(where: { (nodeSet) -> Bool in
            return nodeSet.contains(node3) && nodeSet.contains(node5)
        }))
        XCTAssertEqual(intersections2.count, 2)
        XCTAssertTrue(independents2.isEmpty)

    }
    
    func testIntersectionsTimer() {
        // Given
        let node1 = SKSpriteNode(color: .black, size: CGSize(width: 10, height: 10))
        node1.position = CGPoint(x: 0, y: 0)
        let node2 = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 10))
        node2.position = CGPoint(x: 5, y: 5)
        
        scene.addChild(node1)
        scene.addChild(node2)
        
        let awaitInterval: TimeInterval = 0.1
        let buffer: TimeInterval = 0.3
        
        // When
        scene.startCheckingForNodeIntersections(atInterval: awaitInterval, atGeneration: 0)
        
        // Then
        let wait = expectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + awaitInterval + buffer) {
            wait.fulfill()
        }
        waitForExpectations(timeout: awaitInterval + (buffer * 2), handler: nil)
        XCTAssertNotNil(delegate.intersecting)
        XCTAssertNotNil(delegate.independents)
        XCTAssertEqual(delegate.independents?.count, 0)
        XCTAssertEqual(delegate.intersecting?.count, 1)
        XCTAssertTrue(delegate.intersecting?.contains(where: { (nodeSet) -> Bool in
            return nodeSet.contains(node1) && nodeSet.contains(node2)
        }) == true)
    }
    
    func testTouchOneNode() {
        // Given
        let node1 = SKSpriteNode(color: .black, size: CGSize(width: 10, height: 10))
        node1.position = CGPoint(x: 0, y: 0)
        scene.addChild(node1)
        
        // When
        let touch = MockTouch(location: .zero)
        scene.touchesBegan(Set([touch]), with: nil)
        
        // Then
        XCTAssertNotNil(delegate.tappedNodes)
        XCTAssertEqual(delegate.tappedNodes, [node1])
    }
    
    func testTouchNoNodes() {
        // Given
        let node1 = SKSpriteNode(color: .black, size: CGSize(width: 10, height: 10))
        node1.position = CGPoint(x: 0, y: 0)
        scene.addChild(node1)
        
        // When
        let touch = MockTouch(location: CGPoint(x: 20, y: 0))
        scene.touchesBegan(Set([touch]), with: nil)
        
        // Then
        XCTAssertNotNil(delegate.tappedNodes)
        XCTAssertTrue(delegate.tappedNodes?.isEmpty == true)
    }
    
    func testTouchTwoNodes() {
        // Given
        let node1 = SKSpriteNode(color: .black, size: CGSize(width: 10, height: 10))
        node1.position = CGPoint(x: 0, y: 0)
        let node2 = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 10))
        node2.position = CGPoint(x: 15, y: 0)
        
        scene.addChild(node1)
        scene.addChild(node2)
        
        // When
        let touch1 = MockTouch(location: .zero)
        let touch2 = MockTouch(location: CGPoint(x: 15, y: 0))
        scene.touchesBegan(Set([touch1, touch2]), with: nil)
        
        // Then
        XCTAssertNotNil(delegate.tappedNodes)
        XCTAssertTrue(delegate.tappedNodes?.contains(node1) == true)
        XCTAssertTrue(delegate.tappedNodes?.contains(node2) == true)
    }

}

class MockInteractionDelegate: InteractiveSceneDelegate {
    var intersecting: [[SKNode]]?
    var independents: [SKNode]?
    var tappedNodes: [SKNode]?
    
    func interactiveScene(_ scene: InteractiveScene, didTap nodes: [SKNode]) {
        tappedNodes = nodes
    }
    
    func interactiveScene(_ scene: InteractiveScene, hasIntersectingNodes intersecting: [[SKNode]], notIntersecting independents: [SKNode], atGeneration generation: UInt) {
        self.intersecting = intersecting
        self.independents = independents
    }
}

class MockTouch: UITouch {
    
    let location: CGPoint
    
    init(location: CGPoint) {
        self.location = location
        super.init()
    }
    
    override func location(in node: SKNode) -> CGPoint {
        return location
    }
}
