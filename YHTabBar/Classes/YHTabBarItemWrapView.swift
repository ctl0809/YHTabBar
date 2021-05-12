//
//  YHTabBarItemWrapView.swift
//  Honeybee
//
//  Created by BeeGo-MAC on 2021/5/11.
//  Copyright © 2021 icebartech. All rights reserved.
//

import UIKit

class YHTabBarItemWrapView: UIControl {

    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    init(target: AnyObject?) {
        super.init(frame: .zero)
        backgroundColor = .clear
//        self.addTarget(self, action: #selector(selectAction(sender:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subView in subviews {
            if let subView = subView as? YHTabBarItemContainerView {
                let insets = subView.insets
                /// 设置 YHTabBarItemContainerView 的 frame 将触发`YHTabBarItemContainerView`的`layoutSubviews`方法
                subView.frame = CGRect(x: insets.left, y: insets.top, width: bounds.size.width - insets.left - insets.right, height: bounds.size.height - insets.top - insets.bottom)
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var status = super.point(inside: point, with: event)
        if !status {
            for view in subviews {
                if view.point(inside: CGPoint(x: point.x - bounds.origin.x, y: point.y - bounds.origin.y), with: event) {
                    status = true
                }
            }
        }
        return status
    }
    
}
