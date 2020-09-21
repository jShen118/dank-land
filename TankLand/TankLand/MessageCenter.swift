//
//  MessageCenter.swift
//  TankLand
//
//  Created by Joshua Shen on 5/14/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation
//MessageCenter
struct MessageCenter {
    static var messages = [String: String]()
    
    func sendMessage(id: String, message: String) {
        MessageCenter.messages[id] = message
    }
    
    func receiveMessage(id: String)->String {
        return MessageCenter.messages[id]!
    }
}

