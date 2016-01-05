//
//  ViewController.swift
//  SegmentedControllerExample
//
//  Created by Duc DoBa on 8/26/15.
//  Copyright (c) 2015 Duc Doba. All rights reserved.
//

import UIKit
import SegmentedController

class ViewController: UIViewController {

    @IBOutlet weak var segmentedViewControllerContainer: UIView!
    
    var segmentedVC = SegmentedViewController()
    var didLayoutSubviews: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedViewControllerContainer.addSubview(segmentedVC.view)
        segmentedVC.view.frame = segmentedViewControllerContainer.bounds
        
        segmentedVC.viewControllers = [
            tableViewVCWithColor(UIColor.redColor(), title: "Red"),
            tableViewVCWithColor(UIColor.greenColor(), title: "Green"),
            tableViewVCWithColor(UIColor.blueColor(), title: "Blue")
        ]
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        segmentedVC.segmentedControl.selectedBackgroundColor = UIColor.orangeColor()
    }

    func tableViewVCWithColor(color: UIColor, title: String) -> UITableViewController {
        let tb = UITableViewController(style: .Plain)
        tb.tableView.backgroundColor = color
        tb.title = title
        
        return tb
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (!didLayoutSubviews) {
            for tb in segmentedVC.viewControllers {
                if let tb = tb as? UITableViewController {
                    var frame = segmentedViewControllerContainer.bounds
                    frame.origin.y = segmentedVC.segmentedControl.frame.height
                    frame.size.height = frame.height - segmentedVC.segmentedControl.frame.height
                    tb.tableView.frame = frame
                }
            }
        }
    }
}

