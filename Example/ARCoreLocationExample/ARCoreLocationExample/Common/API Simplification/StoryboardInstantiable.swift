//
//  StoryboardInstantiable.swift
//  ARCoreLocationExample
//
//  Created by Skyler Smith on 2019-01-02.
//  Copyright (c) 2019 Freshworks Studio Inc.. All rights reserved.
//

import UIKit

protocol StoryboardInstantiable: class {
    static func initFromStoryboard() -> Self
}

extension StoryboardInstantiable where Self: UIViewController {
    static func initFromStoryboard() -> Self {
        guard let viewController = UIStoryboard(name: String(describing: self), bundle: nil)
                                    .instantiateInitialViewController() as? Self else {
            fatalError("There is no Storyboard named \(String(describing: self)) with this initial View Controller.")
        }
        return viewController
    }
    
    static func initFromStoryboardInNavigationController() -> (Self, UINavigationController) {
        let name = String(describing: self)
        guard let navigationController = UIStoryboard(name: name, bundle: nil)
            .instantiateInitialViewController() as? UINavigationController,
            let viewController = navigationController.viewControllers.first as? Self else {
                fatalError("There is no Storyboard named \(name)) with a Navigation Controller containing this.")
        }
        return (viewController, navigationController)
    }
}

extension UIViewController: StoryboardInstantiable { }
