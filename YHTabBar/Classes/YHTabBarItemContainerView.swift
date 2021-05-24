//
//  YHTabBarItemContainerView.swift
//  Honeybee
//
//  Created by BeeGo-MAC on 2021/5/11.
//  Copyright © 2021 icebartech. All rights reserved.
//

import UIKit
import Lottie

open class YHTabBarItemContainerView: UIView {

    /// 是否被选中
    var isSelected: Bool = false
    
    /// tabBar
    weak var tabBar: YHTabBar?
    
    /// 偏移量
    var insets = UIEdgeInsets.zero {
        didSet {
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }
    /// 正常状态下文本颜色
    var normalTextColor: UIColor = .systemGray {
        didSet {
            self.updateDisplay()
        }
    }
    
    /// 选中状态下文本颜色
    var selectedTextColor: UIColor = .black {
        didSet {
            self.updateDisplay()
        }
    }
    
    /// 正常态下图片
    public var normalImage: UIImage? {
        didSet {
            self.updateDisplay()
        }
    }
    
    /// 选中状态下图片
    public var selectedImage: UIImage? {
        didSet {
            self.updateDisplay()
        }
    }
    
    /// 图片渲染模式
    public var iconRenderingMode: UIImage.RenderingMode = UIImage.RenderingMode.alwaysOriginal {
        didSet {
            self.updateDisplay()
        }
    }
    
    /// lottie 动画
    var lottieStr: String? {
        didSet {
            updateDisplay()
        }
    }
    
    
    /// 标题
    public var title: String? {
        didSet {
            self.updateDisplay()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    /// 文本字体
    public var font: UIFont = UIFont.systemFont(ofSize: 10, weight: .medium) {
        didSet {
            self.updateDisplay()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        
        updateDisplay()
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        upadteLayout()
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var result = false
        for view in subviews {
            if view.frame.contains(point) {
                result = true
                break
            }
        }
        
        return result
    }
    
    // MARK: ----- custom methods ------
    func initViews() {
        isUserInteractionEnabled = false
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(animationView)
    }
    
    /// 更新
    func updateDisplay() {
        self.imageView.image = (self.isSelected ? (self.selectedImage ?? self.normalImage) : self.normalImage)?.withRenderingMode(self.iconRenderingMode)
        self.titleLabel.textColor = self.isSelected ? self.selectedTextColor : self.normalTextColor
        self.titleLabel.text = self.title
        self.titleLabel.font = self.font
        self.animationView.animation = Animation.named(lottieStr ?? "")
    }
    
    /// 更新约束
    func upadteLayout() {
        self.imageView.isHidden = (self.imageView.image == nil)
        self.titleLabel.isHidden = (self.titleLabel.text ?? "").count <= 0
        
        let w = bounds.size.width
        let h = bounds.size.height
        
        let isLandscape = UIApplication.shared.statusBarOrientation.isLandscape
        let isWide = isLandscape || traitCollection.horizontalSizeClass == .regular
        
        if !imageView.isHidden && !titleLabel.isHidden {
            titleLabel.sizeToFit()
            
            var titleWidth = titleLabel.bounds.size.width
            
            if #available(iOS 11, *), isWide {
                
                let space: CGFloat = 5
                
                titleWidth = min(titleWidth, (w - 20 - space))
                
                let sumWidth: CGFloat = 20 + space + titleWidth
                
                imageView.frame = CGRect(x: (w - sumWidth) / 2, y: (h - 20) / 2, width: 20, height: 20)
                titleLabel.frame = CGRect(x: w - (w - sumWidth) / 2 - titleWidth, y: (h - titleLabel.bounds.size.height) / 2, width: titleWidth, height: titleLabel.bounds.size.height)
                animationView.frame = imageView.frame
                
            } else {
                
                titleWidth = min(titleWidth, w)
                
                titleLabel.frame = CGRect(x: (w - titleWidth) / 2, y: h - titleLabel.bounds.size.height - 2, width: titleWidth, height: titleLabel.bounds.size.height)
                imageView.frame = CGRect(x: (w - 20) / 2, y: (h - 20) / 2 - 6, width: 20, height: 20)
                animationView.frame = imageView.frame
            }
            
        }
        
    }
    
    // MARK: ------ lazy methods ------
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        return titleLabel
    }()
    
    lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "")
        animationView.isUserInteractionEnabled = false
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 1
        return animationView
    }()
    
}

extension YHTabBarItemContainerView {
    /// 选中
    func select(animated: Bool, completion: (() -> ())?) {
        self.isSelected = true
        self.updateDisplay()
        self.select()
    }
    
    /// 取消选中
    func deselect(animated: Bool, completion: (() -> ())?) {
        self.isSelected = false
        self.updateDisplay()
        self.deselect()
        self.imageView.isHidden = false
    }
    
    /// 重新选中
    func reselect(animated: Bool, completion: (() -> ())?) {
        if self.isSelected == false {
            self.select()
        } else {
            self.reselect()
        }
    }
    
    @objc open func select() {
        imageView.isHidden = true
        animationView.play(fromProgress: 0, toProgress: 1) { (finished) in
            self.imageView.isHidden = false
        }
    }
    
    @objc open func deselect() {
        
    }
    
    @objc open func reselect() {
        imageView.isHidden = true
        animationView.play(fromProgress: 0, toProgress: 1) { (finished) in
            self.imageView.isHidden = false
        }
    }
}
