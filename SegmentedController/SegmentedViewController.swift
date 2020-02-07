//
//  SegmentedViewController.swift
//  SegmentedController
//
//  Created by Duc DoBa on 8/26/15.
//  Copyright (c) 2015 Duc Doba. All rights reserved.
//

import UIKit

public class SegmentedViewController: UIViewController {
    @IBOutlet public weak var segmentedControl: SegmentedControl!

    public var viewControllers: [UIViewController] = [] {
        didSet {
            segmentedControl.segments = viewControllers.map( { $0.title ?? "" } )
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init() {
        super.init(nibName: "SegmentedViewController", bundle: Bundle(for: SegmentedViewController.self))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @objc public func didChangeSelectedIndex(sender: SegmentedControl) {
        showChildViewController(viewController: viewControllers[segmentedControl.selectedIndex])
    }
    
    func configure() {
        segmentedControl.addTarget(self, action: #selector(self.didChangeSelectedIndex(sender:)), for: .valueChanged)
    }
}

public extension SegmentedViewController {
    public func showChildViewController(viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    public func hideChildViewController(viewController: UIViewController) {
        viewController.willMove(toParent: self)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    public func switchViewControllers(from: UIViewController, to: UIViewController) {
        from.willMove(toParent: self)
        
        // Alpha only by default
        addChild(to)
        to.view.alpha = 0
        
        transition(
            from: from,
            to: to,
            duration: 0.3,
            options: .curveEaseOut,
            animations: {
                to.view.alpha = 1
                from.view.alpha = 0
        }) { finished in
            from.removeFromParent()
            to.didMove(toParent: self)
        }
    }
}
