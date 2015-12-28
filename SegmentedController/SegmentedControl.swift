//
//  SegmentedControl.swift
//  SegmentedController
//
//  Created by Duc DoBa on 8/26/15.
//  Copyright (c) 2015 Duc Doba. All rights reserved.
//

import UIKit

@IBDesignable
public class SegmentedControl: UIControl {
    // Background
    @IBInspectable public
    var selectedBackgroundViewHeight: CGFloat = 0 { didSet { updateSelectedBackgroundFrame() } }
    
    @IBInspectable public
    var selectedBackgroundColor: UIColor = UIColor.darkGrayColor() { didSet { updateSelectedBackgroundColor() } }
    
    // Title
    @IBInspectable public
    var titleFont: UIFont = UIFont.boldSystemFontOfSize(12) { didSet { updateTitleStyle() } }
    @IBInspectable public
    var titleColor: UIColor = UIColor.darkGrayColor() { didSet { updateTitleStyle() } }
    @IBInspectable public
    var highlightedTitleColor: UIColor = UIColor.yellowColor() { didSet { updateTitleStyle() } }
    @IBInspectable public
    var selectedTitleColor: UIColor = UIColor.whiteColor() { didSet { updateTitleStyle() } }
    
    // Segment
    @IBInspectable public
    var segmentTitles: String = "" { didSet { updateSegments(segmentTitles) } }
    public var segments: [SegmentTitleProvider] = ["Title 1", "Title 2"] { didSet { updateSegments(nil) } }
    public private(set) var segmentItems: [UIButton] = []
    
    // Selected
    @IBInspectable public var selectedIndex: Int = 0 {
        didSet {
            if selectedIndex < 0 {
                selectedIndex = 0
            }
            if selectedIndex > segments.count - 1 {
                selectedIndex = segments.count - 1
            }
            if selectedIndex < segmentItems.count {
                updateSelectedIndex(animationEnabled)
            }
        }
    }
    
    @IBInspectable public var animationEnabled: Bool = true
    
    public let selectedBackgroundView = UIView()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureElements()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureElements()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateSegmentFrames()
        updateSelectedIndex(false)
    }
    
    public func segmentTouched(sender: UIButton) {
        if let index = segmentItems.indexOf(sender) {
            selectedIndex = index
        }
    }
}

// MARK:- Private methods
private extension SegmentedControl {
    func configureElements() {
        insertSubview(selectedBackgroundView, atIndex: 0)
        updateSegments(nil)
    }
    
    func updateSegments(titles: String?) {
        if let titles = titles {
            let extractedTitles = titles.characters.split(100, allowEmptySlices: false, isSeparator: { $0 == "," }).map { String($0) }
            segments = extractedTitles.map({ $0 })
            return
        }
        
        // Clean up first
        for segmentItem in segmentItems {
            segmentItem.removeFromSuperview()
        }
        segmentItems.removeAll(keepCapacity: true)
        
        // Reset data
        if segments.count > 0 {
            let itemWidth: CGFloat = frame.width / CGFloat(segments.count)
            for (index, segment) in segments.enumerate() {
                let item = UIButton(frame: CGRect(
                    x: itemWidth * CGFloat(index),
                    y: 0,
                    width: itemWidth,
                    height: frame.height
                ))

                item.selected = (index == selectedIndex)
                item.setTitle(segment.segmentTitle(), forState: .Normal)
                item.addTarget(self, action: "segmentTouched:", forControlEvents: UIControlEvents.TouchUpInside)

                addSubview(item)
                segmentItems.append(item)
            }
        }
        
        updateTitleStyle()
        updateSelectedIndex(false)
    }
    
    func updateSegmentFrames() {
        if segments.count > 0 {
            let itemWidth: CGFloat = frame.width / CGFloat(segmentItems.count)
            for (index, item) in segmentItems.enumerate() {
                item.frame = CGRect(
                    x: itemWidth * CGFloat(index),
                    y: 0,
                    width: itemWidth,
                    height: frame.height
                )
            }
        }
    }
    
    func updateTitleStyle() {
        for item in segmentItems {
            item.setTitleColor(titleColor, forState: .Normal)
            item.setTitleColor(highlightedTitleColor, forState: .Highlighted)
            item.setTitleColor(selectedTitleColor, forState: .Selected)
            item.titleLabel?.font = titleFont
        }
    }
    
    func updateSelectedIndex(animated: Bool) {
        for item in segmentItems {
            item.selected = false
        }
        if animated {
            UIView.animateWithDuration(0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.updateSelectedBackgroundFrame()
                }, completion: { finished in
                    self.segmentItems[self.selectedIndex].selected = true
                    self.sendActionsForControlEvents(.ValueChanged)
            })
        } else {
            updateSelectedBackgroundFrame()
            segmentItems[selectedIndex].selected = true
            sendActionsForControlEvents(.ValueChanged)
        }
    }
    
    func updateSelectedBackgroundColor() {
        selectedBackgroundView.backgroundColor = selectedBackgroundColor
    }
    
    func updateSelectedBackgroundFrame() {
        if selectedIndex < segmentItems.count {
            let segment = segmentItems[selectedIndex]
            var frame = segment.frame
            frame.size.height = selectedBackgroundViewHeight > 0 ? selectedBackgroundViewHeight : self.frame.height
            frame.origin.y = selectedBackgroundViewHeight > 0 ? self.frame.height - selectedBackgroundViewHeight : 0
     
            selectedBackgroundView.frame = frame
        }
    }
}

// MARK:- Data types, Protocol & Extensions
public protocol SegmentTitleProvider {
    func segmentTitle() -> String
}

extension String: SegmentTitleProvider {
    public func segmentTitle() -> String {
        return self
    }
}

extension UIViewController: SegmentTitleProvider {
    public func segmentTitle() -> String {
        return title ?? ""
    }
}