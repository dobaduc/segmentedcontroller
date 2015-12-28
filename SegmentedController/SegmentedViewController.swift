//
//  SegmentedViewController.swift
//  SegmentedController
//
//  Created by Duc DoBa on 8/26/15.
//  Copyright (c) 2015 Duc Doba. All rights reserved.
//

import UIKit

public class SegmentedViewController: UIViewController {
    @IBOutlet public weak var segmentedControl: SegmentedControl! {
        didSet {
            segmentedControl.selectedBackgroundColor = UIColor.redColor()
        }
    }

    public var viewControllers: [UIViewController] = [] {
        didSet {
            segmentedControl.segments = viewControllers.map( { $0.title ?? "" } )
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init() {
        super.init(nibName: "SegmentedViewController", bundle: NSBundle(forClass: SegmentedViewController.self))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    public func didChangeSelectedIndex(sender: SegmentedControl) {
        showChildViewController(viewControllers[segmentedControl.selectedIndex])
    }
    
    func configure() {
        segmentedControl.addTarget(self, action: "didChangeSelectedIndex:", forControlEvents: .ValueChanged)
    }
}

public extension SegmentedViewController {
    public func showChildViewController(viewController: UIViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
    }

    public func hideChildViewController(viewController: UIViewController) {
        viewController.willMoveToParentViewController(self)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

    public func switchViewControllers(from: UIViewController, to: UIViewController) {
        from.willMoveToParentViewController(self)
        
        // Alpha only by default
        addChildViewController(to)
        to.view.alpha = 0
        
        transitionFromViewController(
            from,
            toViewController: to,
            duration: 0.3,
            options: .CurveEaseOut,
            animations: {
                to.view.alpha = 1
                from.view.alpha = 0
        }) { finished in
            from.removeFromParentViewController()
            to.didMoveToParentViewController(self)
        }
    }
}
