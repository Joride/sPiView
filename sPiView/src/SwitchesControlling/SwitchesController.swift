//
//  SwitchesController.swift
//  sPiView
//
//  Created by Jorrit van Asselt on 11-06-17.
//  Copyright © 2017 KerrelInc. All rights reserved.
//

import Foundation

protocol SwitchesControllerDelegate
{
    // called when any of the switches changes, not caused by
    // the user (i.e. the remote has changed the states for any reason)
    func switchesController(controller: SwitchesController,
                            didChangeSwitchesStates atIndexes: [Int])
    
    func switchesControllerDidGetDisconnected(controller: SwitchesController)
}

class SwitchesController
{
    enum SwitchState
    {
        case on
        case off
        case unknown
    }
    
    var delegate: SwitchesControllerDelegate? = nil
    var switchesState: [SwitchState]{
        get
        {
            return _switchesState
        }
    }
    
    var isConnectedToRemote: Bool{
        get {
            return networkController.isConnected
        }
    }
    
    func toggleSwitch(atIndex index: Int, onOrOff: SwitchState,
                      completion: @escaping (Bool, [SwitchState]) -> Void )
    {
        let messageToSend = message(toChangeSwitchAtIndex: index,
                                    toState: onOrOff)
        if networkController.isConnected
        {
            networkController.sendBytes(bytes: messageToSend, completion: { (succes: Bool, receivedBytes:[UInt8]?) in
                if !succes
                {
                    self._switchesState = [.unknown, .unknown, .unknown, .unknown]
                    completion(false, self._switchesState)
                }
                else
                {
                    if let messageMessageBytes = receivedBytes
                    {
                        let receivedMessage = self.message(fromReceivedBytes: messageMessageBytes)
                        /// MARK: should a callback to the delegate be prevente here,
                        /// as this is a user-initiated change
                        self.updateSwitchesState(withReceivedMessage: receivedMessage)
                        completion(true, self._switchesState)
                    }
                    else
                    {
                        self._switchesState = [.unknown, .unknown, .unknown, .unknown]
                        completion(false, self._switchesState)
                    }
                }
            })
        }
        else
        {
            _switchesState = [.unknown, .unknown, .unknown, .unknown]
            completion(false, _switchesState)
        }
    }
    fileprivate func updateSwitchesState(withReceivedMessage message: [UInt8])
    {
        assert(message.count == 1, "Expecting messages of only 1 byte")
        let statusByte = message[0]
        
        var updatedSwitches: [SwitchState] = []
        for index in 0 ..< 4
        {
            let value = (statusByte >> UInt8(index)) & 1
            let state: SwitchState = (value == 1) ? .on : .off
            updatedSwitches.append(state)
        }
        _switchesState = updatedSwitches
    }
    
    func connectToRemote(completion: @escaping (Bool) -> Void)
    {
        networkController.openConnection { (succes: Bool) in
            completion(succes)
        }
    }
    
    ///
    fileprivate var _switchesState: [SwitchState] = [.unknown, .unknown, .unknown, .unknown]
    {
        didSet {
            var changedIndexes: [Int] = []
            for index in 0 ..< 4
            {
                if oldValue[index] != _switchesState[index]
                {
                    changedIndexes.append(index)
                }
            }
            delegate?.switchesController(controller: self,
                                         didChangeSwitchesStates: changedIndexes)
        }
    }
    
    private let networkController = NetworkController()
    init()
    {
        networkController.delegate = self
    }
    /*
     |   set/req     command  |
     beginOfMes  |   0b0000      0000     |   endOfMes
     ------------|------------------------|-------------
     0b1000 0000 |   0b0001      1100     |   0b1100 0000  // set switch 4 to 1
     0b1000 0000 |   0b0001      0011     |   0b1100 0000  // set switch 3 to 0
     0b1000 0000 |   0b0001      1011     |   0b1100 0000  // set switch 3 to 1
     0b1000 0000 |   0b0001      1001     |   0b1100 0000  // set switch 1 to 1
     0b1000 0000 |   0b0001      1000     |   0b1100 0000  // set switch 0 to 1
     0b1000 0000 |   0b0011      0000     |   0b1100 0000  // request status
     */
    fileprivate let kBeginOfMessage: UInt8              = 0b10000000
    fileprivate let kEndOfMessage: UInt8                = 0b11000000
    fileprivate let kClientRequestStatusMessage: UInt8  = 0b00100000
    fileprivate let kClientModifyStatusMessage: UInt8   = 0b00010000
}

extension SwitchesController
{
    fileprivate func message(toChangeSwitchAtIndex index: Int,
                             toState: SwitchState) -> [UInt8]
    {
        assert(index < 4, "There are only 4 switches, an index > 3 is impossible. Given index is: \(index).")
        let value: UInt8 = (toState == .on) ? 1 << 3 : 0
        let command =
                kClientModifyStatusMessage |
                UInt8(index) |
                value
        let message = [kBeginOfMessage, command, kEndOfMessage]
        return message
    }
    fileprivate func messageToRequestSwitchesStatus() -> [UInt8]
    {
        return [kBeginOfMessage, kClientRequestStatusMessage, kEndOfMessage];
    }
    fileprivate func message(fromReceivedBytes bytes: [UInt8]) -> [UInt8]
    {
        var message = [UInt8]()
        var messageStarted = false
        for aByte in bytes
        {
            if aByte == kBeginOfMessage
            {
                message = []
                messageStarted = true
            }
            else if aByte == kEndOfMessage
            {
                break
            }
            else
            {
                if messageStarted
                {
                    message.append(aByte)
                }
            }
        }
        return message
    }
}
extension SwitchesController: NetworkControllerDelegate
{
    func networkController(controller: NetworkController,
                           didReceiveBytes: [UInt8])
    {
        // parse the message and update the switchesState
        let receivedMessage = message(fromReceivedBytes: didReceiveBytes)
        updateSwitchesState(withReceivedMessage: receivedMessage)
    }
    func networkController(controller: NetworkController,
                           didChangeConnectionState isConnected: Bool)
    {
        if !isConnected
        {
            delegate?.switchesControllerDidGetDisconnected(controller: self)
        }
    }
}
