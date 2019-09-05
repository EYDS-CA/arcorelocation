//
//  InteractiveScene.swift
//  ARCoreLocation
//
//  Created by Skyler Smith on 2018-09-21.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import SpriteKit

protocol InteractiveSceneDelegate: class {
    func interactiveScene(_ scene: InteractiveScene, didTap nodes: [SKNode]) -> Void
    func interactiveScene(_ scene: InteractiveScene, hasIntersectingNodes intersecting: [[SKNode]], notIntersecting independents: [SKNode], atGeneration generation: UInt) -> Void
}

/*
 TODO:
 
 This class uses a very inefficient and cumbersome algorithm for finding intersecting nodes.
 A better approach would be to us the SKScene's PhysicsWorld's SKPhysicsContactDelegate.
 Each landmark can have a physics body, and we can wait for contacts.
 
 */

public class InteractiveScene: SKScene {
    weak var interactionDelegate: InteractiveSceneDelegate?
    private var intersectionTimer: Timer?
    
    /// Request the scene to check for node intersections and notify the interactionDelegate when there are.
    /// - parameter interval: The seconds between each intersection check
    /// - parameter searchGeneration: The generation of nodes to search. 0 indicates the children of the receiver, 1 indicates the children of those children, etc.
    public func startCheckingForNodeIntersections(atInterval interval: TimeInterval, atGeneration searchGeneration: UInt) {
        intersectionTimer?.invalidate()
        intersectionTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            if let me = self {
                let (intersections, independents) = me.intersectingNodes(searchGeneration: searchGeneration)
                me.interactionDelegate?.interactiveScene(me, hasIntersectingNodes: intersections, notIntersecting: independents, atGeneration: searchGeneration)
            }
        }
    }
    
    /// Request the scene to stop checking for node intersections
    public func stopCheckingForNodeIntersections() {
        intersectionTimer?.invalidate()
        intersectionTimer = nil
    }
    
    /// Get all the nodes that are intersecting at the given generation
    /// - parameter searchGeneration: The generation of nodes to search. 0 indicates the children of the receiver, 1 indicates the children of those children, etc.
    public func intersectingNodes(searchGeneration: UInt) -> (intersecting: [[SKNode]], independent: [SKNode]) {
        var intersections = Set<Set<SKNode>>()
        var nodes = children
        for _ in 0..<searchGeneration {
            nodes = nodes.flatMap({ $0.children })
        }
        for (i, node) in nodes.enumerated() {
            for otherNode in nodes[(i + 1)...] {
                if node.parent!.convert(rect: node.frame, to: self).intersects(otherNode.parent!.convert(rect: otherNode.frame, to: self)) {
                    intersections.insert(Set([node, otherNode]))
                }
            }
        }
        let joinedIntersections = SetMerger.mergeByCommonElements(sets: intersections)
        let notIntersecting = Set(nodes).subtracting(Set(joinedIntersections.flatMap({ $0 })))
        return (intersecting: joinedIntersections.map({ (nodeSet) -> [SKNode] in nodeSet.map({ $0 }) }), independent: Array(notIntersecting))
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var tappedNodes: [SKNode] = []
        var handled = Set<UITouch>()
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if node !== self {
                tappedNodes.append(node)
            }
            // Mark touch as handled
            handled.insert(touch)
        }
        let unhandled = touches.subtracting(handled)
        if !unhandled.isEmpty {
            // Only forward touches that weren't already handled
            super.touchesBegan(unhandled, with: event)
        }
        interactionDelegate?.interactiveScene(self, didTap: tappedNodes)
    }
}

extension SKNode {
    func convert(rect: CGRect, to node: SKNode) -> CGRect {
        let xDiff = abs(convert(rect.maxXminY, to: node).x - convert(rect.minXminY, to: node).x)
        let yDiff = abs(convert(rect.minXmaxY, to: node).y - convert(rect.minXminY, to: node).y)
        return CGRect(origin: convert(rect.origin, to: node), size: CGSize(width: xDiff, height: yDiff))
    }
}
