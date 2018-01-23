//
//  SegmentedControl.swift
//  SegmentedController
//
//  Created by Duc DoBa on 8/26/15.
//  Copyright (c) 2015 Duc Doba. All rights reserved.
//

import UIKit

public enum AnimationType {
    case bounce
    case fade
    case slide
    case none
}

@IBDesignable
public class SegmentedControl: UIControl {
    // Background
    @IBInspectable public
    var selectedBackgroundViewHeight: CGFloat = 0 { didSet { updateSelectedBackgroundFrame() } }
    
    @IBInspectable public
    var selectedBackgroundColor: UIColor = UIColor.darkGray { didSet { updateSelectedBackgroundColor() } }
    
    // Title
    @IBInspectable public
    var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 12) { didSet { updateTitleStyle() } }
    @IBInspectable public
    var titleColor: UIColor = UIColor.darkGray { didSet { updateTitleStyle() } }
    @IBInspectable public
    var highlightedTitleColor: UIColor = UIColor.yellow { didSet { updateTitleStyle() } }
    @IBInspectable public
    var selectedTitleColor: UIColor = UIColor.white { didSet { updateTitleStyle() } }
    
    // Segment
    @IBInspectable public
    var segmentTitles: String = "" { didSet { updateSegments(titles: segmentTitles) } }
    public var segments: [SegmentTitleProvider] = ["Title 1", "Title 2"] { didSet { updateSegments(titles: nil) } }
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
                updateSelectedIndex(animated: true)
            }
        }
    }
    
    public var animationType: AnimationType = .bounce
    
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
        updateSelectedIndex(animated: false)
    }
    
    @objc public func segmentTouched(sender: UIButton) {
        if let index = segmentItems.index(of: sender) {
            selectedIndex = index
        }
    }
}

// MARK:- Private methods
private extension SegmentedControl {
    func configureElements() {
        insertSubview(selectedBackgroundView, at: 0)
        updateSegments(titles: nil)
    }
    
    func updateSegments(titles: String?) {
        if let titles = titles {
            let extractedTitles = titles.split(separator: ",").map { String($0) }
            segments = extractedTitles.map({ $0 })
            return
        }
        
        // Clean up first
        for segmentItem in segmentItems {
            segmentItem.removeFromSuperview()
        }
        segmentItems.removeAll(keepingCapacity: true)
        
        // Reset data
        if segments.count > 0 {
            let itemWidth: CGFloat = frame.width / CGFloat(segments.count)
            for (index, segment) in segments.enumerated() {
                let item = UIButton(frame: CGRect(
                    x: itemWidth * CGFloat(index),
                    y: 0,
                    width: itemWidth,
                    height: frame.height
                ))

                item.isSelected = (index == selectedIndex)
                item.setTitle(segment.segmentTitle(), for: .normal)
                item.addTarget(self, action: #selector(self.segmentTouched(sender:)), for: UIControlEvents.touchUpInside)

                addSubview(item)
                segmentItems.append(item)
            }
        }
        
        updateTitleStyle()
        updateSelectedIndex(animated: false)
    }
    
    func updateSegmentFrames() {
        if segments.count > 0 {
            let itemWidth: CGFloat = frame.width / CGFloat(segmentItems.count)
            for (index, item) in segmentItems.enumerated() {
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
            item.setTitleColor(titleColor, for: .normal)
            item.setTitleColor(highlightedTitleColor, for: .highlighted)
            item.setTitleColor(selectedTitleColor, for: .selected)
            item.setTitleColor(selectedTitleColor, for: .disabled)
            item.titleLabel?.font = titleFont
        }
    }
    
    func updateSelectedIndex(animated: Bool) {
        for item in segmentItems {
            item.isSelected = false
            
            if animated {
                switch animationType {
                case .bounce, .fade, .slide:
                    item.fadeTransition(0.2)
                case .none:
                    break
                }
            }
        }
        
        self.segmentItems[self.selectedIndex].isSelected = true
        self.sendActions(for: .valueChanged)
        
        if animated {
            switch animationType {
            case .bounce:
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 0.3,
                               options: UIViewAnimationOptions.curveEaseOut,
                               animations: {
                                self.updateSelectedBackgroundFrame()
                }, completion: nil)
            case .fade:
                self.fadeTransition(0.2)
                self.updateSelectedBackgroundFrame()
            case .slide:
                UIView.animate(withDuration: 0.1, animations: {
                    self.updateSelectedBackgroundFrame()
                })
            case .none:
                self.updateSelectedBackgroundFrame()
            }
        } else {
            self.updateSelectedBackgroundFrame()
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

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionFade)
    }
}
