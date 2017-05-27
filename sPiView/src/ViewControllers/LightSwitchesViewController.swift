//
//  LightSwitchesViewController.swift
//  sPiView
//
//  Created by Jorrit van Asselt on 27-05-17.
//  Copyright © 2017 KerrelInc. All rights reserved.
//

import UIKit

class LightSwitchesViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupButton()
    }
    
    private lazy var button: UIButton = {
        let aButton = UIButton(type: .system)
        aButton.addTarget(self,
                          action: #selector(LightSwitchesViewController.toggleLights),
                          for: .touchUpInside)
        aButton.translatesAutoresizingMaskIntoConstraints = false
        
        aButton.backgroundColor = UIColor.white
        self.view.addSubview(aButton)
        return aButton
    }()
    
    private func setupButton()
    {
        button.setTitle("SET", for: .normal)
        
        let centerY = NSLayoutConstraint(item: button,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: view ,
                                         attribute: .centerY,
                                         multiplier: 1.0,
                                         constant: 0)
        let centerX = NSLayoutConstraint(item: button,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: view ,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0)
        view.addConstraints([centerY, centerX])
    }
    
    private var buttonTapped = false
    func toggleLights()
    {
        buttonTapped = !buttonTapped
        if buttonTapped
        {
            view.backgroundColor = UIColor.black
        }
        else
        {
            view.backgroundColor = UIColor.white
        }
    }
}

