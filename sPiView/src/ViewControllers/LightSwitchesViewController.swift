//
//  LightSwitchesViewController.swift
//  sPiView
//
//  Created by Jorrit van Asselt on 10-06-17.
//  Copyright © 2017 KerrelInc. All rights reserved.
//

import UIKit

class LightSwitchesViewController: UIViewController
{
    var imageView: UIImageView{
        get {
            assert(self.view is UIImageView, "Expecting self.view to be of type UIImaView")
            return view as! UIImageView
            
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            self.imageView.image = UIImage.launch()
            if size.width > size.height
            {
                self.spinnerTop?.constant = 2
                self.stackBottom?.constant = -2
            }
            else
            {
                self.spinnerTop?.constant = 40
                self.stackBottom?.constant = -40
            }
        })
        { (context: UIViewControllerTransitionCoordinatorContext) in
            
        }
    }
    fileprivate let switchesController = SwitchesController()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var buttons: [JRTCircleVibrantView] = []
    var spinnerTop: NSLayoutConstraint? = nil
    var stackBottom: NSLayoutConstraint? = nil
    let label = UILabel()
    private func setupUI()
    {
        let button0 = JRTCircleVibrantView(blurEffect: UIBlurEffect(style: .light))
        button0.translatesAutoresizingMaskIntoConstraints = false
        button0.delegate = self
        button0.text = "?"
        button0.isHidden = true
        
        let button1 = JRTCircleVibrantView(blurEffect: UIBlurEffect(style: .light))
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.delegate = self
        button1.text = "?"
        button1.isHidden = true
        
        let button2 = JRTCircleVibrantView(blurEffect: UIBlurEffect(style: .light))
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.delegate = self
        button2.text = "?"
        button2.isHidden = true
        
        let button3 = JRTCircleVibrantView(blurEffect: UIBlurEffect(style: .light))
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.delegate = self
        button3.text = "?"
        button3.isHidden = true
        
        buttons = [button0, button1, button2, button3]
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Not connected"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(LightSwitchesViewController.connectionLabelWasTapped(tapGestureRecognizer:)))
        label.addGestureRecognizer(tapGestureRecognizer)
        label.isUserInteractionEnabled = true
        
        // spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor.raspberryPiGreen()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        view.addSubview(spinner)
        
        let stackView = UIStackView(arrangedSubviews: [button0, button1/*, button2, button3*/, label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing//.equalCentering
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.contentView.addSubview(stackView)
        effectView.contentView.addSubview(spinner)
        
        view!.addSubview(effectView)
        
        let stackLeading = NSLayoutConstraint(item: stackView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: effectView.contentView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0)
        let stackTrailing = NSLayoutConstraint(item: stackView,
                                               attribute: .trailing,
                                               relatedBy: .equal,
                                               toItem: effectView.contentView,
                                               attribute: .trailing,
                                               multiplier: 1.0,
                                               constant: 0)
        let spinnerCenterX = NSLayoutConstraint(item: spinner,
                                        attribute: .centerX,
                                        relatedBy: .equal,
                                        toItem: effectView.contentView,
                                        attribute: .centerX,
                                        multiplier: 1.0,
                                        constant: 0)
        spinnerTop = NSLayoutConstraint(item: spinner,
                                      attribute: .top,
                                      relatedBy: .equal,
                                      toItem: effectView.contentView,
                                      attribute: .top,
                                      multiplier: 1.0,
                                      constant: 100)
        let stackTop = NSLayoutConstraint(item: stackView,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: spinner,
                                               attribute: .bottom,
                                               multiplier: 1.0,
                                               constant: 20)
        stackBottom = NSLayoutConstraint(item: stackView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: effectView.contentView,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: -100)
        
        let effectLeading = NSLayoutConstraint(item: effectView,
                                               attribute: .leading,
                                               relatedBy: .equal,
                                               toItem: view!,
                                               attribute: .leading,
                                               multiplier: 1.0,
                                               constant: 0)
        let effectTrailing = NSLayoutConstraint(item: effectView,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: view!,
                                                attribute: .trailing,
                                                multiplier: 1.0,
                                                constant: 0)
        let effectTop = NSLayoutConstraint(item: effectView,
                                           attribute: .top,
                                           relatedBy: .equal,
                                           toItem: topLayoutGuide,
                                           attribute: .bottom,
                                           multiplier: 1.0,
                                           constant: 0)
        let effectBottom = NSLayoutConstraint(item: effectView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bottomLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: -0)
        
        view!.addConstraints([stackLeading, stackTrailing,
                              stackBottom!, stackTop,
                              
                              spinnerTop!, spinnerCenterX,
                              
                              effectLeading, effectTrailing,
                              effectTop, effectBottom])
        
    }
    
    func connectionLabelWasTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if !switchesController.isConnectedToRemote
        {
            label.text = "Connecting..."
            switchesController.connectToRemote(completion: { (succes: Bool) in
                DispatchQueue.main.async {
                    if succes
                    {
                        self.label.text = "Connected"
                        for aButton in self.buttons
                        {
                            aButton.isHidden = false
                        }
                    }
                    else
                    {
                        self.label.text = "Not Connected, tap to connect"
                        for aButton in self.buttons
                        {
                            aButton.isHidden = true
                        }
                    }
                }
            })
        }
    }
    fileprivate func updateButton(button: JRTCircleVibrantView,
                              forState state: SwitchesController.SwitchState)
    {
        switch state
        {
        case .on:
            button.text = "ON"
        case .off:
            button.text = "OFF"
        case .unknown:
            button.text = "?"
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        switchesController.delegate = self
        title =  NSLocalizedString("Switches", comment: "")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        switchesController.delegate = self
        title =  NSLocalizedString("Switches", comment: "")
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = NSLocalizedString("Switches", comment: "")
        imageView.image = UIImage.launch()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if !switchesController.isConnectedToRemote
        {
            switchesController.connectToRemote(completion: { (didConnect: Bool) in
                DispatchQueue.main.async
                    {
                        self.spinner.stopAnimating()
                        self.updateUIForConnectedToRemote(isConnected: didConnect)
                }
            })
        }
    }
    
    func updateUIForConnectedToRemote(isConnected: Bool)
    {
        if isConnected
        {
            for aButton in buttons
            {
                aButton.isHidden = false
            }
            label.text = "Connected"
        }
        else
        {
            for aButton in buttons
            {
                aButton.isHidden = true
            }
            label.text = "No Connected, tap to connect"
        }
    }
}

extension LightSwitchesViewController: SwitchesControllerDelegate
{
    func switchesControllerDidGetDisconnected(controller: SwitchesController)
    {
        // update the UI to reflec the current state
        DispatchQueue.main.async {
            self.updateUIForConnectedToRemote(isConnected: false)
        }
    }
    func switchesController(controller: SwitchesController,
                            didChangeSwitchesStates atIndexes: [Int])
    {
        // update the buttons to reflect the new state
        DispatchQueue.main.async {
            for anIndex in atIndexes
            {
                self.updateButton(button: self.buttons[anIndex],
                                  forState: controller.switchesState[anIndex])
            }
        }
    }
}

extension LightSwitchesViewController: JRTCircleVibrantViewDelegate
{
    func circleVibrantViewDidGetTapped(view: JRTCircleVibrantView)
    {
        if let index = buttons.index(of: view)
        {
            if index != NSNotFound
            {
                spinner.startAnimating()
                for aButton in buttons
                {
                    aButton.isUserInteractionEnabled = false
                }
                let onOrOff: SwitchesController.SwitchState
                switch switchesController.switchesState[index]
                {
                case .off, .unknown:
                    onOrOff = .on
                case .on:
                    onOrOff = .off
                }
                switchesController.toggleSwitch(atIndex: index,
                                                onOrOff: onOrOff,
                                                completion: { (succes: Bool, updatedState: [SwitchesController.SwitchState]) in
                                                    for aButton in self.buttons
                                                    {
                                                        aButton.isUserInteractionEnabled = true
                                                    }
                                                    if succes
                                                    {
                                                        // update the UI to
                                                        // reflect the new state
                                                        DispatchQueue.main.async {
                                                            self.spinner.stopAnimating()
                                                            self.updateButton(button: view,
                                                                              forState: onOrOff)
                                                        }
                                                    }
                                                    else
                                                    {
                                                        // nothing changed
                                                        DispatchQueue.main.async {
                                                            self.spinner.stopAnimating()
                                                            self.updateButton(button: view,
                                                                              forState: .unknown)
                                                        }
                                                    }
                })
            }
        }
    }
}
