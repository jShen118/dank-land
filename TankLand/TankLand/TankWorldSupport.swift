//
//  TankWorldSupport.swift
//  TankLand
//
//  Created by Joshua Shen on 5/12/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation
//TankWorld Support Code
extension TankWorld {
    func positionHelper(position: Position, direction: Direction, distance: Int)-> Position {
        var newPosition = Position(0,0)
        switch direction {
            case .North: newPosition = Position(position.row + distance, position.col)
            case .East: newPosition = Position(position.row, position.col + distance)
            case .South: newPosition = Position(position.row - distance, position.col)
            case .West: newPosition = Position(position.row, position.col - distance)
            case .Northeast: newPosition = Position(position.row + distance, position.col + distance)
            case .Southeast: newPosition = Position(position.row - distance, position.col + distance)
            case .Southwest: newPosition = Position(position.row - distance, position.col - distance)
            case .Northwest: newPosition = Position(position.row + distance, position.col - distance)
        }
        return newPosition
    }
    
    func positionLegal(position: Position)-> Bool {
        if position.row < 0 || position.row > self.numberRows - 1 || position.col < 0 || position.col > self.numberCols - 1 {
            return false
        }
        if grid[position.row][position.col] != nil {
            if grid[position.row][position.col]!.objectType == .Tank {
                return false
            }
        }
        return true
    }
    
    func radarHelper(position: Position, radius: Int) ->[Position] {
        var result = [Position]()
        for row in 0..<numberRows{
            for col in 0..<numberCols{
                if row <= position.row + radius && row >= position.row - radius && col <= position.col + radius && col >= position.col - radius{
                    result.append(Position(row, col))
                }
            }
        }
        return result
    }
    
    func isEnergyAvailable(_ gameObject: GameObject, amount: Int) -> Bool{
        if amount >= gameObject.energy{
            return false
        }
        return true
    }
    
    func isDead(_ tank: Tank)-> Bool {
        if tank.energy <= 0 {
            return true
        }
        return false
    }
    
    func lifeSupport() {
        for go in allObjects {
            let oldEnergy = go.energy
            if go.objectType == .Tank {go.applyCost(Constants.costLifeSupportTank)}
            if go.objectType == .Mine {
                if (go as! Mine).isRover {go.applyCost(Constants.costLifeSupportRover)}
                else {go.applyCost(Constants.costLifeSupportMine)}
            }
            logger.addLog(go, "Life Support, energy dropped from \(oldEnergy) to \(go.energy)")
        }
    }
    
    mutating func clearDead() {
        for go in allObjects {
            if go.energy <= 0 {kill(go)}
        }
    }
    
    func numberTanksAlive()-> Int {
        var result = 0
        for go in allObjects {
            if go.objectType == .Tank {result += 1}
        }
        return result
    }
    
    func roverPositionLegal(position: Position)-> Bool {
        if position.row < 0 || position.row > self.numberRows - 1 || position.col < 0 || position.col > self.numberCols - 1 {
            return false
        }
        return true
    }
    
    mutating func moveRover(rover: Mine) {
        var newPosition = Position(0,0)
        var direction: Direction
        if rover.moveDirection == nil {
            direction = getRandomDirection()
            newPosition = positionHelper(position: rover.position, direction: direction, distance: 1)
        } else {
            direction = rover.moveDirection!
            newPosition = positionHelper(position: rover.position, direction: rover.moveDirection!, distance: 1)
        }
        
        if roverPositionLegal(position: newPosition){
            if isEnergyAvailable(rover, amount: Constants.costOfMovingRover) {
                if grid[newPosition.row][newPosition.col] != nil {
                    if grid[newPosition.row][newPosition.col]!.objectType == .Mine {
                        kill(rover)
                        kill(grid[newPosition.row][newPosition.col]!)
                    } else {
                        kill(rover)
                        (grid[newPosition.row][newPosition.col]! as! Tank).applyCost(rover.energy * Constants.mineStrikeMultiple)
                        if isDead(grid[newPosition.row][newPosition.col]! as! Tank) {kill(grid[newPosition.row][newPosition.col]! as! Tank)}
                    }
                } else {
                    grid[rover.position.row][rover.position.col] = nil
                    rover.position = newPosition
                    grid[newPosition.row][newPosition.col] = rover
                    rover.applyCost(Constants.costOfMovingRover)
                    logger.addLog(rover, "moved 1 unit \(direction)")
                }
            } else {logger.addLog(rover, "insufficient energy to move")}
        } else {logger.addLog(rover, "tried to move out of bounds")}
    }
    
    mutating func moveAllRovers() {
        for go in allObjects {
            if go.objectType == .Mine {
                if (go as! Mine).isRover {
                    moveRover(rover: go as! Mine)
                }
            }
        }
    }
    
    func isAvailable(_ tank: Tank, _ key: Actions)-> Bool {
        if tank.preActions[key] == nil && tank.postActions[key] == nil {return false}
        return true
    }
    
    func doAllPreActionComputation() {
        for go in allObjects {
            if go.objectType == .Tank {
                (go as! Tank).computePreActions()
            }
        }
    }
    
    func doAllPostActionComputation() {
        for go in allObjects {
            if go.objectType == .Tank {
                (go as! Tank).computePostActions()
            }
        }
    }
    
    func doAllPreActions() {
        for go in allObjects {
            if go.objectType == .Tank {
                let tank = go as! Tank
                if isAvailable(tank, .RunRadar) {actionRunRadar(tank: tank, runRadarAction: tank.preActions[.RunRadar]! as! RadarAction)}
                if isAvailable(tank, .SendMessage) {actionSendMessage(tank: tank, sendMessageAction: tank.preActions[.SendMessage]! as! SendMessageAction)}
                if isAvailable(tank, .ReceiveMessage) {actionReceiveMessage(tank: tank, receiveMessageAction: tank.preActions[.ReceiveMessage]! as! ReceiveMessageAction)}
                if isAvailable(tank, .SetShields) {actionSetShields(tank: tank, setShieldsAction: tank.preActions[.SetShields] as! ShieldAction)}
            }
        }
    }
    
    mutating func doAllPostActions() {
        for go in allObjects {
            if go.objectType == .Tank {
                let tank = go as! Tank
                if isAvailable(tank, .Drop) {actionDrop(tank: tank, dropAction: tank.postActions[.Drop] as! DropMineAction)}
                if isAvailable(tank, .FireMissile) {actionFireMissile(tank: tank, fireMissileAction: tank.postActions[.FireMissile] as! MissileAction)}
                if isAvailable(tank, .Move) {actionMove(tank: tank, moveAction: tank.postActions[.Move] as! MoveAction)}
            }
        }
    }
}

func getRandomInt(range: Int)->Int {
    return Int(arc4random_uniform(UInt32(range)))
}

func getRandomDirection()->Direction {
    let randomNumber = getRandomInt(range: 7)
    switch randomNumber {
    case 0: return .North
    case 1: return .East
    case 2: return .South
    case 3: return .West
    case 4: return .Northeast
    case 5: return .Northwest
    case 6: return .Southeast
    case 7: return .Southwest
    default: return .North
    }
}

func distanceHelper(_ a: Position, _ b: Position)-> Double {
    let horizontal: Int
    let vertical: Int
    if a.row > b.row {horizontal = a.row - b.row} else {horizontal = b.row - a.row}
    if a.col > b.col {vertical = a.col - b.col} else {vertical = b.col - a.col}
    return sqrt(Double(horizontal * horizontal + vertical * vertical))
}
