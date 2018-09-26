//
//  SetMerger.swift
//  ARCoreLocation
//
//  Created by Skyler Smith on 2018-09-21.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import Foundation

struct SetMerger {
    public static func mergeByCommonElements<T>(sets: Set<Set<T>>) -> Set<Set<T>> {
        var lastResult: Set<Set<T>>? = nil
        var newResult = sets
        while (lastResult != newResult) {
            lastResult = newResult
            newResult = newResult.reduce(Set<Set<T>>()) { (result, set) -> Set<Set<T>> in
                var buildableResult = result
                if let mergeable = buildableResult.first(where: { !$0.isDisjoint(with: set) }) {
                    let merged = mergeable.union(set)
                    buildableResult.remove(mergeable)
                    buildableResult.insert(merged)
                } else {
                    buildableResult.insert(set)
                }
                return buildableResult
            }
        }
        return newResult
    }
}
