//
//  TankWorldTurn.swift
//  TankLand
//
//  Created by Joshua Shen on 6/6/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation
//TankWorld Turn
extension TankWorld {
    func randomizeGameObjects(gameObjects: [GameObject])-> [GameObject] {
        var tanks = [Tank]()
        for go in gameObjects {
            if go.objectType == .Tank {tanks.append(go as! Tank)}
        }
        
        var old: Tank
        var index: Int
        var new: Tank
        var result = tanks
        
        for i in 0..<result.count {
            old = result[i]
            index = getRandomInt(range: (result.count - 1))
            new = result[index]
            result[i] = new
            result[index] = old
        }
        return result
    }

    mutating func doTurn() {
        print("TURN #\(turn)")
        print("Number of Tanks alive: \(numberTanksAlive())")
        lifeSupport()
        clearDead()
        moveAllRovers()
        doAllPreActionComputation()
        doAllPreActions()
        doAllPostActionComputation()
        allObjects = randomizeGameObjects(gameObjects: allObjects)
        doAllPostActions()
        turn += 1
        logger.turn += 1
    }
    
    mutating func runOneTurn() {
        doTurn()
        gridReport()
    }
}
