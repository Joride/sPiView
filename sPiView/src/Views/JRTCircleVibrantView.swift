//
//  JRTCircleVibrantView.swift
//  HighlightviewTest
//
//  Created by Jorrit van Asselt on 04-06-17.
//  Copyright © 2017 Visible Ninja. All rights reserved.
//

import UIKit

protocol JRTCircleVibrantViewDelegate
{
    func circleVibrantView(didGetTapped: JRTCircleVibrantView)
}

class JRTCircleVibrantView: UIVisualEffectView
{
    enum VisualState
    {
        case highlighted
        case normal
    }
    
    private var _state = VisualState.normal
    var state: VisualState{
        get
        {
            return _state
        }
    }
    func setState(state: VisualState)
    {
        if shapeLayer.animation(forKey: kAnimationKey) != nil
        {
            shapeLayer.removeAnimation(forKey: kAnimationKey)
        }
        updateShapelayer()
    }
    var delegate: JRTCircleVibrantViewDelegate? = nil
    var text: String?{
        set
        {
            label.text = newValue
        }
        get
        {
            return label.text
        }
    }
    
    fileprivate let shapeLayer = CAShapeLayer()
    fileprivate let label = UILabel()
    let vibrancyView: UIVisualEffectView
    private let lineWidth: CGFloat = 4.00 / UIScreen.main.scale
    required init(blurEffect: UIBlurEffect)
    {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = lineWidth
        
        label.text = "1"
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        label.textColor = UIColor.white
        label.textAlignment = .center
        
        super.init(effect: blurEffect)
        
        contentView.addSubview(vibrancyView)
        contentView.layer.addSublayer(shapeLayer)
        // the label should always stay as it is, 
        // so it is not added to the contentview
        vibrancyView.addSubview(label)
        vibrancyView.contentView.layer.addSublayer(shapeLayer)
        
        clipsToBounds = true
        layer.cornerRadius = 37.5000
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(JRTCircleVibrantView.labelTapped(recognizer:)))
        self.addGestureRecognizer(recognizer)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        vibrancyView.frame = bounds
        label.frame = vibrancyView.bounds
        
        let ovalRect = vibrancyView.bounds.insetBy(dx: 0.5 * lineWidth, dy: 0.5 * lineWidth)
        shapeLayer.frame = vibrancyView.bounds
        shapeLayer.path = UIBezierPath(ovalIn: ovalRect).cgPath
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect())
        vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        super.init(coder: aDecoder)
        precondition(false, "Call init(effect:) to initialize this class")
    }
    
    fileprivate let kAnimationKey = "MyFillColorAnimation"
    func labelTapped(recognizer: UITapGestureRecognizer)
    {
        if shapeLayer.animation(forKey: kAnimationKey) != nil
        {
            shapeLayer.removeAnimation(forKey: kAnimationKey)
            updateShapelayer()
        }
        
        let animation = CABasicAnimation(keyPath: "fillColor")
        animation.duration = 0.60
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.fillMode = "forwards"
        
        let toValue: CGColor?
        if _state == .normal
        {
            toValue = UIColor.white.cgColor
            _state = .highlighted
        }
        else
        {
            toValue = UIColor.clear.cgColor
            _state = .normal
        }
        
        animation.toValue = toValue
        shapeLayer.add(animation, forKey: kAnimationKey)
        
        delegate?.circleVibrantView(didGetTapped: self)
    }
    override var intrinsicContentSize: CGSize
    {
        return CGSize(width: 75, height: 75)
    }
    
    
    func updateShapelayer()
    {
        if state == .normal
        {
            shapeLayer.fillColor = UIColor.clear.cgColor
        }
        else
        {
            shapeLayer.fillColor = UIColor.white.cgColor
        }
    }
}

extension JRTCircleVibrantView: CAAnimationDelegate
{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
        shapeLayer.removeAnimation(forKey: kAnimationKey)
        updateShapelayer()
    }
}

