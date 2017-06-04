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
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
    var buttons: [UIButton] = []
    private func setupUI()
    {
        // button0
        let button0 = UIButton(type: .system)
        button0.addTarget(self,
                          action: #selector(LightSwitchesViewController.lightButtonTapped(button:)),
                          for: .touchUpInside)
        button0.translatesAutoresizingMaskIntoConstraints = false
        button0.backgroundColor = UIColor.white
        button0.setTitle("Switch0 - ?", for: .normal)
        button0.layer.borderColor = button0.currentTitleColor.cgColor
        button0.layer.borderWidth = 1.000 / UIScreen.main.scale
        self.view.addSubview(button0)
        
        let button0Leading = NSLayoutConstraint(item: button0
            , attribute: .leading,
              relatedBy: .equal,
              toItem: self.view!,
              attribute: .leading,
              multiplier: 1,
              constant: 10)
        let button0Trailing = NSLayoutConstraint(item: button0
            , attribute: .trailing,
              relatedBy: .equal,
              toItem: self.view!,
              attribute: .trailing,
              multiplier: 1,
              constant: -10)
        let button0Top = NSLayoutConstraint(item: button0
            , attribute: .top,
              relatedBy: .equal,
              toItem: self.topLayoutGuide,
              attribute: .bottom,
              multiplier: 1,
              constant: 20)
        view.addSubview(button0)
        view.addConstraints([button0Leading, button0Trailing, button0Top])
        
        // button1
        let button1 = UIButton(type: .system)
        button1.addTarget(self,
                          action: #selector(LightSwitchesViewController.lightButtonTapped(button:)),
                          for: .touchUpInside)
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.backgroundColor = UIColor.white
        button1.setTitle("Switch1 - ?", for: .normal)
        button1.layer.borderColor = button0.currentTitleColor.cgColor
        button1.layer.borderWidth = 1.000 / UIScreen.main.scale
        self.view.addSubview(button1)
        
        let button1Leading = NSLayoutConstraint(item: button1
            , attribute: .leading,
              relatedBy: .equal,
              toItem: self.view!,
              attribute: .leading,
              multiplier: 1,
              constant: 10)
        let button1Trailing = NSLayoutConstraint(item: button1
            , attribute: .trailing,
              relatedBy: .equal,
              toItem: self.view!,
              attribute: .trailing,
              multiplier: 1,
              constant: -10)
        let button1Top = NSLayoutConstraint(item: button1
            , attribute: .top,
              relatedBy: .equal,
              toItem: button0,
              attribute: .bottom,
              multiplier: 1,
              constant: 20)
        view.addSubview(button1)
        view.addConstraints([button1Leading, button1Trailing, button1Top])
        
        
        // button2
        let button2 = UIButton(type: .system)
        button2.addTarget(self,
                          action: #selector(LightSwitchesViewController.lightButtonTapped(button:)),
                          for: .touchUpInside)
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.backgroundColor = UIColor.white
        button2.setTitle("Switch2 - ?", for: .normal)
        button2 .layer.borderColor = button0.currentTitleColor.cgColor
        button2.layer.borderWidth = 1.000 / UIScreen.main.scale
        self.view.addSubview(button2)
        
        let button2Leading = NSLayoutConstraint(item: button2
            , attribute: .leading,
              relatedBy: .equal,
              toItem: self.view!,
              attribute: .leading,
              multiplier: 1,
              constant: 10)
        let button2Trailing = NSLayoutConstraint(item: button2
            , attribute: .trailing,
              relatedBy: .equal,
              toItem: self.view!,
              attribute: .trailing,
              multiplier: 1,
              constant: -10)
        let button2Top = NSLayoutConstraint(item: button2
            , attribute: .top,
              relatedBy: .equal,
              toItem: button1,
              attribute: .bottom,
              multiplier: 1,
              constant: 20)
        view.addSubview(button2)
        view.addConstraints([button2Leading, button2Trailing, button2Top])
        
        // button3
        let button3 = UIButton(type: .system)
        button3.addTarget(self,
                          action: #selector(LightSwitchesViewController.lightButtonTapped(button:)),
                          for: .touchUpInside)
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.backgroundColor = UIColor.white
        button3.setTitle("Switch3 - ?", for: .normal)
        button3.layer.borderColor = button0.currentTitleColor.cgColor
        button3.layer.borderWidth = 1.000 / UIScreen.main.scale
        self.view.addSubview(button3)
        
        let button3Leading = NSLayoutConstraint(item: button3
            , attribute: .leading,
              relatedBy: .equal,
              toItem: self.view!,
              attribute: .leading,
              multiplier: 1,
              constant: 10)
        let button3Trailing = NSLayoutConstraint(item: button3
            , attribute: .trailing,
              relatedBy: .equal,
              toItem: self.view!,
              attribute: .trailing,
              multiplier: 1,
              constant: -10)
        let button3Top = NSLayoutConstraint(item: button3
            , attribute: .top,
              relatedBy: .equal,
              toItem: button2,
              attribute: .bottom,
              multiplier: 1,
              constant: 20)
        view.addSubview(button3)
        view.addConstraints([button3Leading, button3Trailing, button3Top])
        
        buttons = [button0, button1, button2, button3]
        
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
    
    func lightButtonTapped(button: UIButton)
    {
        if let index = buttons.index(of: button)
        {
            if index != NSNotFound
            {
                spinner.startAnimating()
                toggleSwitch(atIndex: index)
            }
        }
    }
    
    private func toggleSwitch(atIndex: Int)
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
                button.setTitle(buttonTitle, for: .normal)
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
