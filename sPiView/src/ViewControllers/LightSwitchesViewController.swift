//
//  LightSwitchesViewController.swift
//  sPiView
//
//  Created by Jorrit van Asselt on 27-05-17.
//  Copyright © 2017 KerrelInc. All rights reserved.
//

import UIKit

fileprivate let kPortNumber = 82

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
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            
        }
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title =  NSLocalizedString("Switches", comment: "")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title =  NSLocalizedString("Switches", comment: "")
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = NSLocalizedString("Switches", comment: "")
        
        imageView.image = UIImage.launch()
        
        setupUI()
        
        if nil == _socket
        {
            let queue: DispatchQueue = DispatchQueue(label: "com.sPiView.LightSwitchesViewControllerQueue")
            _socket = JRTSocket(host: "192.168.1.33",
                                portNumber: NSNumber(integerLiteral: kPortNumber),
                                receiver: self,
                                callbackQueue: queue)
        }
    }
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var buttons: [JRTCircleVibrantView] = []
    private func setupUI()
    {
        let button0 = JRTCircleVibrantView(blurEffect: UIBlurEffect(style: .light))
        button0.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button0)
        button0.delegate = self
        button0.text = "?"
        
        let button1 = JRTCircleVibrantView(blurEffect: UIBlurEffect(style: .light))
        button1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button1)
        button1.delegate = self
        button1.text = "?"
        
        let button2 = JRTCircleVibrantView(blurEffect: UIBlurEffect(style: .light))
        button2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button2)
        button2.delegate = self
        button2.text = "?"
        
        let button3 = JRTCircleVibrantView(blurEffect: UIBlurEffect(style: .light))
        button3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button3)
        button3.delegate = self
        button3.text = "?"
        
        buttons = [button0, button1, button2, button3]
        
        let stackView = UIStackView(arrangedSubviews: [button0, button1, button2, button3])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        view.addSubview(stackView)
        
        let leading = NSLayoutConstraint(item: stackView,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: view!,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0)
        let trailing = NSLayoutConstraint(item: stackView,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: view!,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 0)
        let top = NSLayoutConstraint(item: stackView,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: topLayoutGuide,
                                   attribute: .bottom,
                                   multiplier: 1.0,
                                   constant: 20)
        let bottom = NSLayoutConstraint(item: stackView,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: bottomLayoutGuide,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: -20)
        
        view!.addConstraints([leading, trailing, top, bottom])
        
        
        
        let message = self.message
        if message.count > 0
        {
            decodeMessage(bytes: message)
        }
        
        // spinner
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor.raspberryPiGreen()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        view.addSubview(spinner)
        
        let spinnerCenterY = NSLayoutConstraint(item: spinner,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .centerY,
                                            multiplier: 1,
                                            constant: 0)
        let spinnerCenterX = NSLayoutConstraint(item: spinner,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .centerX,
                                                multiplier: 1,
                                                constant: 0)
        view.addConstraints([spinnerCenterY, spinnerCenterX])
    }
    
//    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animate(alongsideTransition: { (<#UIViewControllerTransitionCoordinatorContext#>) in
//            <#code#>
//        }, completion: <#T##((UIViewControllerTransitionCoordinatorContext) -> Void)?##((UIViewControllerTransitionCoordinatorContext) -> Void)?##(UIViewControllerTransitionCoordinatorContext) -> Void#>)
//    }
    
    
    fileprivate func toggleSwitch(atIndex: Int)
    {
        precondition(atIndex < 4, "There are only 4 switches, yet the index exceeds 4")
        
        if (self.message.count > 0)
        {
            let switchesState = self.message[0] & 0b00001111 // lose the most significant 4 bits
            let mask: UInt8 = UInt8(0x01 << atIndex)
            
            let isOn = (switchesState & mask) == mask
            
            var command = switchesState | kClientModifyStatusMessage
            if isOn
            {
                // the switch is on, we want to turn it off:
                // & 0b11110111
                //         ^ this is the index
                let mask = UInt8(1 << atIndex)
                let invertedMask = ~mask
                command &= invertedMask
                
            }
            else
            {
                // the switch is off, we want to turn it on:
                // | 0b00001000
                //         ^ this is the index
                command |= UInt8((1 << atIndex))
            }
        
            
            var message = [kBeginOfMessage, command, kEndOfMessage]
            
            print("Sending: \(String(command, radix: 2))")
            socket.writeBytes(&message, length: 3)
        }
    }
    
    var _socket: JRTSocket? = nil
    var socket: JRTSocket {
        get {
            if nil == _socket
            {
                let queue: DispatchQueue = DispatchQueue(label: "com.sPiView.LightSwitchesViewControllerQueue")
                _socket = JRTSocket(host: "192.168.1.33",
                                    portNumber: NSNumber(integerLiteral: kPortNumber),
                                    receiver: self,
                                    callbackQueue: queue)
            }
            return _socket!
        }
    }
    
    let kBeginOfMessage: UInt8              = 0b10000000
    let kEndOfMessage: UInt8                = 0b11000000
    let kClientRequestStatusMessage: UInt8  = 0b00100000
    
    // The least significatn 4 bits indicate the
    // values to be set on the switches:
    // example: switch 1 on: 0b00010001
    // example: switch 3 on: 0b00010100
    // example: switch 2 and 4 on: 0b00011010
    let kClientModifyStatusMessage: UInt8 = 0b01000000
    
    private func messageToTurnOnSwitches(switchIndexes: [Int]) -> [UInt8]
    {
        precondition(switchIndexes.count < 5) // there are only 4 switches
        var switchCommand: UInt8 = kClientModifyStatusMessage
        for aSwitchIndex in switchIndexes
        {
            assert(aSwitchIndex < 4, "There are only 4 switches, index cannot be > 3")
            switchCommand |= UInt8(1) << UInt8(aSwitchIndex)
        }
        return [kBeginOfMessage, switchCommand, kEndOfMessage]
    }
    
    private func sendOnMessage()
    {
        var bytes = messageToTurnOnSwitches(switchIndexes: [0])
        socket.writeBytes(&bytes,
                          length: bytes.count)
    }
    private func sendOffMessage()
    {
        var bytes = messageToTurnOnSwitches(switchIndexes: [])
        socket.writeBytes(&bytes,
                          length: bytes.count)
    }
    var message: [UInt8] = [UInt8]()
}

extension LightSwitchesViewController: JRTSocketReceiver
{
    func socketOpened(_ socket: JRTSocket)
    {
        spinner.stopAnimating()
    }
    
    func socketClosed(_ socket: JRTSocket)
    {
        _socket = nil
    }
    
    func socket(_ socket: JRTSocket,
                didReceiveDataIn inputStream: InputStream)
    {
        let bufferSize = 4
        var buffer: [UInt8] = Array(repeating: 0, count: bufferSize)
        var result = Int.max
        var responseSize = 0
        while inputStream.hasBytesAvailable && result > 0
        {
            result = inputStream.read(&buffer, maxLength: bufferSize)
            
            if result > 0
            {
                responseSize += result
            }
            else if result == 0
            {
                // end of stream
            }
            else // result < 0
            {
                print("ERROR reading from inputstream: '\(result)'")
            }
        }
        
        let message = parseReceivedDataIntoMesage(bytes: buffer)
        decodeMessage(bytes: message)
    }
    
    func decodeMessage(bytes: [UInt8])
    {
        // there is only one possibility currently, only validate
        assert(bytes.count == 1, "The Raspberry Pi is currently only expected to return message byte: kClientRequestStatusMessage")
        assert(bytes[0] & kClientRequestStatusMessage == kClientRequestStatusMessage, "The Rasberry Pi is currently expected to only return a single byte that indicates the status of four switches via a byte of type kClientRequestStatusMessage")
        
        DispatchQueue.main.async {
            for index in 0..<4
            {
                let mask = UInt8(1) << UInt8(index)
                let switchStatus = (bytes[0] & mask == mask)
                
                let buttonTitle = "Switch \(index): \(switchStatus ? "ON" : "OFF")"
                print(buttonTitle)
                
                // update the UI to reflect the switchStatus
                let button = self.buttons[index]
                button.text = "\(index)"
                let state: JRTCircleVibrantView.VisualState = switchStatus ? .highlighted : .normal
                button.setState(state: state)
            }
            self.spinner.stopAnimating()
        }
    }
    
    
    func parseReceivedDataIntoMesage(bytes: [UInt8]) -> [UInt8]
    {
        print("Data received: \(bytes)")
        var message = [UInt8]()
        for aByte in bytes
        {
            if aByte == kBeginOfMessage
            {
                message = []
            }
            else if aByte == kEndOfMessage
            {
                break
            }
            else
            {
                message.append(aByte)
            }
        }
        self.message = message
        return message
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
                toggleSwitch(atIndex: index)
            }
        }
    }
}
