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
        print("\(socket)")
    }
    
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
            sendOnMessage()
        }
        else
        {
            view.backgroundColor = UIColor.white
            sendOffMessage()
        }
    }
    
    private func sendOnMessage()
    {
        var bytes: [UInt8] = [0b10000000, 1, 0b11000000]
        socket.writeBytes(&bytes,
                          length: 3)
    }
    private func sendOffMessage()
    {
        var bytes: [UInt8] = [0b10000000, 0, 0b11000000]
        socket.writeBytes(&bytes,
                          length: 3)
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
    
    private lazy var socket: JRTSocket = {
        let queue: DispatchQueue = DispatchQueue(label: "com.sPiView.LightSwitchesViewControllerQueue")
        let aSocket = JRTSocket(host: "192.168.1.33",
                                portNumber: 82,
                                receiver: self,
                                callbackQueue: queue)
        return aSocket
    }()
}

extension LightSwitchesViewController: JRTSocketReceiver
{
    func socketClosed(_ socket: JRTSocket)
    {
        
    }
    
    func socket(_ socket: JRTSocket,
                didReceiveDataIn inputStream: InputStream)
    {
        var buffer: [UInt8] = Array(repeating: 0, count: 1024)
        var result = Int.max
        var responseSize = 0
        while inputStream.hasBytesAvailable && result > 0
        {
            result = inputStream.read(&buffer, maxLength: 1024)
            
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
        
        for index in 0 ..< responseSize
        {
            print("\(String(buffer[index], radix: 2))")
        }
    }
}
