//
//  NetworkController.swift
//  sPiView
//
//  Created by Jorrit van Asselt on 06-06-17.
//  Copyright © 2017 KerrelInc. All rights reserved.
//

import Foundation

protocol NetworkControllerDelegate: class
{
    func networkController(controller: NetworkController,
                           didChangeConnectionState isConnected: Bool)
    
    func networkController(controller: NetworkController,
                           didReceiveBytes: [UInt8])
}

class NetworkController: NSObject
{
    weak var delegate: NetworkControllerDelegate? = nil
    var isConnected: Bool{
        get
        {
            return _isConnected
        }
    }
    
    fileprivate let timerQueue = DispatchQueue(label: "NetworkController.timerqueue")
                                           
    fileprivate var openConnectionCompletionHandler: ((Bool) -> Void)? = nil
    func openConnection(withTimeout timeInterval: TimeInterval,
                        completion: @escaping (Bool) -> Void)
    {
        if nil != openConnectionCompletionHandler
        {
            // already busy opening a connection
            completion(false)
        }
        if !isConnected
        {
            startSocket(withTimeout: timeInterval, completion: completion)
        }
    }
    
    fileprivate var timoutTimerFired = false
    fileprivate var timer: Timer? = nil
    private func startSocket(withTimeout timeInterval: TimeInterval,
                             completion: @escaping (Bool) -> Void)
    {
        self.timerQueue.sync {
            self.timoutTimerFired = false
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval,
                                     repeats: false) { (timer: Timer) in
                                        self.timerQueue.async {
                                            if !self.isConnected
                                            {
                                                self.timoutTimerFired = true
                                                self.timerFiredOrConnectionFinished()
                                            }
                                        }
        }
        
        openConnectionCompletionHandler = completion
        socket = nil
        let kPortNumber = 82
        let queue: DispatchQueue = DispatchQueue(label: "com.sPiView.NetworkControllerQueue")
        socket = JRTSocket(host: "192.168.1.33",
                           portNumber: NSNumber(integerLiteral: kPortNumber),
                           receiver: self,
                           callbackQueue: queue)
    }
    
    fileprivate func timerFiredOrConnectionFinished()
    {
        if self.timoutTimerFired
        {
            self.socket = nil
            self.timer?.invalidate()
            self.timer = nil
            if let completion = self.openConnectionCompletionHandler
            {
                completion(false)
            }
            self.openConnectionCompletionHandler = nil
        }
        else
        {
            if let completion = self.openConnectionCompletionHandler
            {
                self.callDelegateForConnectionChange = false
                self._isConnected = true
                self.callDelegateForConnectionChange = true
                self.openConnectionCompletionHandler = nil
                completion(true)
            }
        }
    }
    
    fileprivate var sendMessageCompletionHandler: ((Bool, [UInt8]) -> Void)? = nil
    func sendBytes(bytes: [UInt8], completion: @escaping (Bool, [UInt8]?) -> Void )
    {
        if nil != sendMessageCompletionHandler || !isConnected
        {
            // sendBytes was called before, but no bytes have been received yet
            // or we are currently not connected
            print("Not sending bytes, a previous sendBytes call is not finished yet")
            completion(false, nil)
        }
        else
        {
            assert(socket != nil, "Programming error: the socket must not be nil is isConnected is true")
            // write the bytes into the socket
            print("Sending bytes: \(bytes)")
            sendMessageCompletionHandler = completion
            var mutableBytes = bytes
            socket!.writeBytes(&mutableBytes, length: mutableBytes.count)
        }
    }
    
    fileprivate var socket: JRTSocket? = nil
    fileprivate var callDelegateForConnectionChange = true
    fileprivate var _isConnected = false
    {
        didSet
        {
            if callDelegateForConnectionChange
            {
                delegate?.networkController(controller: self,
                                            didChangeConnectionState: _isConnected)
            }
        }
    }
}

extension NetworkController: JRTSocketReceiver
{
    func socketClosed(_ socket: JRTSocket)
    {
        print("socketClosed")
        self.timerQueue.async {
            self._isConnected = false
        }
        
    }
    func socketOpened(_ socket: JRTSocket)
    {
        print("socketOpened")
        
        self.timerQueue.async {
            if self.timoutTimerFired
            {
                // too late
                self.socket = nil
            }
            else
            {
                // in time
                self._isConnected = true
                self.timerFiredOrConnectionFinished()
            }
        }
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
            
            // MARK: What if the stream has more then 4 bytes available?
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
        
        print("socketdidReceiveDataIninputStream: \(buffer)")
        if let completion = sendMessageCompletionHandler
        {
            sendMessageCompletionHandler = nil
            completion(true, buffer)
        }
        else
        {
            delegate?.networkController(controller: self,
                                        didReceiveBytes: buffer)
        }
    }
}
