//
//  Actions.swift
//  TankLand
//
//  Created by Joshua Shen on 5/7/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation

//ACTIONS AND DIRECTION ENUM AND ACTION PROTOCOLS
enum Direction {
    case North, Northeast, East, Southeast, South, Southwest, West, Northwest
}

enum Actions {
    case Drop, Move, FireMissile, SendMessage, ReceiveMessage, RunRadar, SetShields
}

protocol Action: CustomStringConvertible {
    var action: Actions {get}
    var description: String {get}
}

protocol PreAction: Action {}
protocol PostAction: Action {}


struct MoveAction: PostAction {
    let direction: Direction
    let distance: Int
    let action: Actions
    
    init(direction: Direction, distance: Int) {
        self.direction = direction
        self.distance = distance
        action = .Move
    }
    
    var description: String {
        return "Move\ndirection: \(direction), distance: \(distance)"
    }
}


struct DropMineAction: PostAction {
    let isRover: Bool
    let power: Int
    let dropDirection: Direction?
    let moveDirection: Direction?
    let action: Actions
    
    init(power: Int, isRover: Bool = false, dropDirection: Direction? = nil, moveDirection: Direction? = nil) {
        self.isRover = isRover
        self.dropDirection = dropDirection
        self.moveDirection = moveDirection
        self.power = power
        action = .Drop
    }
    
    var description: String {
        let dropDirectionMessage = (dropDirection == nil) ? "drop direction is random" : "\(dropDirection!)"
        let moveDirectionMessage = (moveDirection == nil) ? "move direction is random" : "\(moveDirection!)"
        return "\(action) \(power) \(dropDirectionMessage) \(isRover) \(moveDirectionMessage)"
    }
}

struct MissileAction: PostAction {
    let power: Int
    let target: Position
    let action: Actions
    
    init(power: Int, target: Position) {
        self.power = power
        self.target = target
        action = .FireMissile
    }
    
    var description: String {
        return "Missile Fire\npower: \(power), position: \(target)"
    }
}








//PREACTIONS
struct SendMessageAction: PreAction {
    let idCode: String
    let text: String
    let action: Actions
    
    init(idCode: String, text: String) {
        self.idCode = idCode
        self.text = text
        action = .SendMessage
    }
    
    var description: String {
        return "Message Send\nID Code: \(idCode), Message: \(text)"
    }
}

struct ReceiveMessageAction: PreAction {
    let idCode: String
    let action: Actions
    
    init(idCode: String) {
        self.idCode = idCode
        action = .ReceiveMessage
    }
    
    var description: String {
        return "Message Receive\nID Code: \(idCode)"
    }
}

struct RadarAction: PreAction {
    let radius: Int
    let action: Actions
    
    init(radius: Int) {
        self.radius = radius
        action = .RunRadar
    }
    
    var description: String {
        return "Radar Run\nRadius: \(radius)"
    }
}

struct ShieldAction: PreAction {
    let power: Int
    let action: Actions
    
    init(power: Int) {
        self.power = power
        action = .SetShields
    }
    
    var description: String {
        return "Shield Set\nEnergy Transferred: \(power)"
    }
}

