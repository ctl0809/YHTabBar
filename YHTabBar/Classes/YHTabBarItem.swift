//
//  YHTabBarItem.swift
//  Honeybee
//
//  Created by BeeGo-MAC on 2021/5/11.
//  Copyright © 2021 icebartech. All rights reserved.
//

import UIKit

class YHTabBarItem: UITabBarItem {
    
    weak var tabBar: YHTabBar?
    var containerView: YHTabBarItemContainerView?
    
    init(containerView: YHTabBarItemContainerView) {
        super.init()
        self.containerView = containerView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
