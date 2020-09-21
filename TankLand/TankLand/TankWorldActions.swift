//
//  TankWorldActions.swift
//  TankLand
//
//  Created by Joshua Shen on 5/12/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation
//TankWorld Actions
extension TankWorld {
    func actionSendMessage(tank: Tank, sendMessageAction: SendMessageAction) {
        if isDead(tank){return}
        logger.addLog(tank, "Sending Message \(sendMessageAction)")
        
        if !isEnergyAvailable(tank, amount: Constants.SendingMessage) {
            logger.addLog(tank, "Insufficient energy to send Message")
            return
        }
        
        tank.applyCost(Constants.SendingMessage)
        self.messageCenter.sendMessage(id: sendMessageAction.idCode, message: sendMessageAction.text)
    }
    
    func actionReceiveMessage(tank: Tank, receiveMessageAction: ReceiveMessageAction) {
        if isDead(tank){return}
        logger.addLog(tank, "Receiving Message \(receiveMessageAction)")
        
        if !isEnergyAvailable(tank, amount: Constants.ReceivingMessage) {
            logger.addLog(tank, "Insufficient energy to receive Message")
            return
        }
        
        tank.applyCost(Constants.ReceivingMessage)
        let message = self.messageCenter.receiveMessage(id: receiveMessageAction.idCode)
        tank.setReceivedMessage(receivedMessage: message)
    }
    
    func actionRunRadar(tank: Tank, runRadarAction: RadarAction) {
        if isDead(tank){return}
        if !isEnergyAvailable(tank, amount: Constants.costOfRadarPerUnitsDistance[runRadarAction.radius]) {
            logger.addLog(tank, "Tried to run a radar of radius \(runRadarAction.radius) but does not have enough energy")
            return
        }
        var radarResult = [RadarResult]()
        for position in radarHelper(position: tank.position, radius: runRadarAction.radius){
            if grid[position.row][position.col] != nil {
                radarResult.append(RadarResult(position: grid[position.row][position.col]!.position, id: grid[position.row][position.col]!.id, energy: grid[position.row][position.col]!.energy))
            }
        }
        logger.addLog(tank, "Ran a radar of radius \(runRadarAction.radius)")
        tank.applyCost(Constants.costOfRadarPerUnitsDistance[runRadarAction.radius])
        tank.setRadarResult(radarResults: radarResult)
    }
    
    func actionSetShields(tank: Tank, setShieldsAction: ShieldAction) {
        if isDead(tank){return}
        if !isEnergyAvailable(tank, amount: setShieldsAction.power) {
            logger.addLog(tank, "Attempted to set a shield but does not have enough energy")
            return
        }
        tank.setShield(amount: setShieldsAction.power * Constants.shieldPowerMultiple)
        tank.applyCost(setShieldsAction.power)
        logger.addLog(tank, "Setting shields to \(setShieldsAction.power)")
    }
    
    mutating func actionDrop(tank: Tank, dropAction: DropMineAction) {
        if isDead(tank){return}
        var dropPosition: Position
        if dropAction.dropDirection != nil {dropPosition = positionHelper(position: tank.position, direction: dropAction.dropDirection!, distance: 1)}
        else {dropPosition = positionHelper(position: tank.position, direction: getRandomDirection(), distance: 1)}
        
        if !positionLegal(position: dropPosition) {
            logger.addLog(tank, "The drop position is out of bounds or already taken")
            return
        }
        tank.applyCost(dropAction.power)
        
        if dropAction.moveDirection != nil {
            grid[dropPosition.row][dropPosition.col] = Mine(row: dropPosition.row, col: dropPosition.col, energy: dropAction.power, isRover: dropAction.isRover, moveDirection: dropAction.moveDirection)
        } else {grid[dropPosition.row][dropPosition.col] = Mine(row: dropPosition.row, col: dropPosition.col, energy: dropAction.power, isRover: dropAction.isRover)}
        addGameObject(gameObject: grid[dropPosition.row][dropPosition.col]!)
        logger.addLog(tank, "dropped a Mine/Rover with energy \(dropAction.power). Energy dropped from \(tank.energy + dropAction.power) to \(tank.energy)")
    }
    
    mutating func actionMove(tank: Tank, moveAction: MoveAction) {
        if isDead(tank){return}
        let newPosition = positionHelper(position: tank.position, direction: moveAction.direction, distance: moveAction.distance)
        if positionLegal(position: newPosition) {
            if isEnergyAvailable(tank, amount: Constants.costOfMovingTankPerUnitDistance[moveAction.distance]) == true {
                if grid[newPosition.row][newPosition.col] != nil {
                    if grid[newPosition.row][newPosition.col]!.objectType == .Mine {
                        kill(grid[newPosition.row][newPosition.col]!)
                        tank.applyCost(grid[newPosition.row][newPosition.col]!.energy * Constants.mineStrikeMultiple)
                        if isDead(tank) {kill(tank)}
                    }
                }
                grid[tank.position.row][tank.position.col] = nil
                tank.position = newPosition
                grid[newPosition.row][newPosition.col] = tank
                tank.applyCost(Constants.costOfMovingTankPerUnitDistance[moveAction.distance - 1])
                if isDead(tank) {kill(tank)}
                logger.addLog(tank, "moved \(moveAction.distance) units \(moveAction.direction), energy dropped from \(tank.energy + Constants.costOfMovingTankPerUnitDistance[moveAction.distance]) to \(tank.energy)")
            } else {logger.addLog(tank, "Insufficent energy to move")}
        } else {logger.addLog(tank, "tried to move illegally \(moveAction.distance) units \(moveAction.direction)")}
    }
    
    mutating func actionFireMissile(tank: Tank, fireMissileAction: MissileAction) {
        if isDead(tank){return}
        let missilePosition = fireMissileAction.target
        if positionLegal(position: missilePosition) {
            if isEnergyAvailable(tank, amount: fireMissileAction.power + Constants.costOfLaunchingMissile + Constants.costOfFlyingMissilePerUnitDistance * Int(distanceHelper(tank.position, missilePosition))) {
                tank.applyCost(fireMissileAction.power + Constants.costOfLaunchingMissile + Constants.costOfFlyingMissilePerUnitDistance * Int(distanceHelper(tank.position, missilePosition)))
                logger.addLog(tank, "Fired missile to position \(missilePosition). Energy dropped from \(tank.energy + fireMissileAction.power + Constants.costOfLaunchingMissile + Constants.costOfFlyingMissilePerUnitDistance * Int(distanceHelper(tank.position, missilePosition))) to \(tank.energy)")
                let damage = fireMissileAction.power * Constants.missileStrikeMultiple
                for position in radarHelper(position: missilePosition, radius: 1) {
                    if grid[position.row][position.col] != nil {
                        let oldEnergy = grid[position.row][position.col]!.energy
                        
                        if position.row == missilePosition.row && position.col == missilePosition.col {
                            grid[position.row][position.col]!.applyCost(damage)
                            if grid[position.row][position.col]!.energy <= 0 {kill(grid[position.row][position.col]!)}
                        }
                        else {
                            grid[position.row][position.col]!.applyCost(damage / 4)
                            if grid[position.row][position.col]!.energy <= 0 {kill(grid[position.row][position.col]!)}
                        }
                        
                        if grid[position.row][position.col] != nil {
                            if grid[position.row][position.col]!.objectType == .Mine {kill(grid[position.row][position.col]!)}
                            if damage >= grid[position.row][position.col]!.energy && grid[position.row][position.col]!.objectType == .Tank {
                                tank.applyCost(oldEnergy / -4)
                                kill(grid[position.row][position.col]!)
                            }
                        }
                    }
                }
            } else {logger.addLog(tank, "Not enough energy to fire missile")}
        } else {logger.addLog(tank, "Cannot fire missile out of bounds")}
    }
}
