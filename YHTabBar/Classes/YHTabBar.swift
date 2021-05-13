//
//  YHTabBar.swift
//  Honeybee
//
//  Created by BeeGo-MAC on 2021/5/11.
//  Copyright © 2021 icebartech. All rights reserved.
//

import UIKit

public protocol YHTabBarDelegate {
    func tabBar(tabBar: YHTabBar, shouldSelect item: UITabBarItem) -> Bool
    func tabBar(tabBar: YHTabBar, canSelect item: UITabBarItem) -> Bool
    func tabBar(tabBar: YHTabBar, didSelect item: UITabBarItem)
}

public class YHTabBar: UITabBar {

    public var tabBardelegate: YHTabBarDelegate?
    public var didSelectIndexClosure: ((Int)->())?
    
    var beforSelectIndex: Int = -1
    let baseTag: Int = 1000
    var wrapViews: [YHTabBarItemWrapView] = []
    
    /// 偏移量，影响所有item。当`layoutType`为`fillUp`时有效
    public var inset: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    /// 设置items，由系统调用，开发者最好不要手动设置该属性
    public override var items: [UITabBarItem]? {
        didSet {
            updateDisplay()
        }
    }
    
    public override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        updateDisplay()
    }
    
    public override func beginCustomizingItems(_ items: [UITabBarItem]) {
        super.beginCustomizingItems(items)
    }
    
    public override func endCustomizing(animated: Bool) -> Bool {
        return super.endCustomizing(animated: animated)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        //
        self.updateLayout()
    }
    
    public override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var b = super.point(inside: point, with: event)
        if !b {
            for v in self.wrapViews {
                if v.point(inside: CGPoint(x: point.x - v.frame.origin.x, y: point.y - v.frame.origin.y), with: event) {
                    b = true
                }
            }
        }
        return b
    }
    
    func updateDisplay() {
        //
        for v in self.wrapViews {
            v.removeFromSuperview()
        }
        self.wrapViews.removeAll()
        //
        guard let tabBarItems = self.items else {
            return
        }
        if tabBarItems.count <= 0 {
            return
        }
        //
        for (index, item) in tabBarItems.enumerated() {
            let wrapView = YHTabBarItemWrapView(target: self)
            wrapView.addTarget(self, action: #selector(selectAction(_:)), for: .touchUpInside)
            wrapView.tag = baseTag + index // 设置tag
            self.addSubview(wrapView)
            self.wrapViews.append(wrapView)
            if let item = item as? YHTabBarItem, let containerView = item.containerView {
                item.tabBar = self
                containerView.tabBar = self
                wrapView.addSubview(containerView)
            }
        }
        // 触发`layoutSubviews`
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func updateLayout() {
        guard let tabBarItems = self.items else {
            return
        }
        if tabBarItems.count <= 0 {
            return
        }
        
        let originTabBarButtons = subviews.filter { (subView) -> Bool in
            if let cls = NSClassFromString("UITabBarButton") { // 获取系统button
                return subView.isKind(of: cls)
            }
            return false
        }.sorted { (view1, view2) -> Bool in
            return view1.frame.origin.x < view2.frame.origin.x
        }
        //
        if originTabBarButtons.count != tabBarItems.count {
            return
        }
        if originTabBarButtons.count != self.wrapViews.count {
            return
        }
        //
        var buttons: [UIView] = [] /* 包含系统`tabBar`按钮和`_GLTabBarItemWrapView` */
        for (index, item) in tabBarItems.enumerated() {
            let wrapView = self.wrapViews[index]
            let sysButton = originTabBarButtons[index]
            if let _ = item as? YHTabBarItem {
                sysButton.isHidden = true
                wrapView.isHidden = false
                buttons.append(wrapView)
            } else {
                sysButton.isHidden = false
                wrapView.isHidden = true
                buttons.append(sysButton)
            }
        }
        if buttons.count != tabBarItems.count {
            return
        }
        
        for (index, w) in buttons.enumerated() {
            w.frame = originTabBarButtons[index].frame
        }
    }
}

extension YHTabBar {
    @objc internal func selectAction(_ sender: AnyObject?) {
        guard let v = sender as? YHTabBarItemWrapView else {
            return
        }
        
        let newIndex = max(0, v.tag - baseTag) // 获取index
        self._select(newIndex: newIndex)
    }
    
    internal func _select(newIndex: Int) {
        guard let item = self.items?[newIndex] else {
            return
        }
        
        // 将要选中的回调
        if (self.tabBardelegate?.tabBar(tabBar: self, shouldSelect: item) ?? true) == false {
            return
        }
        
        // 拦截选中事件
        if (self.tabBardelegate?.tabBar(tabBar: self, canSelect: item) ?? false) == true {
            self.tabBardelegate?.tabBar(tabBar: self, didSelect: item)
            return
        }
        
        if self.beforSelectIndex != newIndex { /* 当前选中的索引和之前选中的索引不同 */
            if self.beforSelectIndex >= 0 && self.beforSelectIndex <= self.items?.count ?? 0 {
                if let currentItem = self.items?[self.beforSelectIndex] as? YHTabBarItem {
                    currentItem.containerView?.deselect(animated: false, completion: nil) // 之前的item取消选中
                }
            }
            if let item = item as? YHTabBarItem {
                item.containerView?.select(animated: false, completion: nil) // 选中当前item
            }
        } else {
            if let item = item as? YHTabBarItem { /* 当前选中的索引和之前选中的索引相同，重新选中 */
                item.containerView?.reselect(animated: false, completion: nil) // 重新选中了之前的item
            }
        }
        // 重新赋值
        self.beforSelectIndex = newIndex
        
        // 回调出去，给tabBarVc使用
        self.didSelectIndexClosure?(newIndex)
    }
}
