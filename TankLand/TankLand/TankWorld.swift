//
//  TankWorld.swift
//  TankLand
//
//  Created by Joshua Shen on 5/7/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation

//TANKWORLD
struct TankWorld {
    var grid: [[GameObject?]]
    var numberRows: Int
    var numberCols: Int
    
    var allObjects = [GameObject]()
    var turn = 0
    var gameOver = false
    var logger = Logger()
    let messageCenter = MessageCenter()
    
    init(numberRows: Int, numberCols: Int) {
        self.numberRows = numberRows
        self.numberCols = numberCols
        grid = Array(repeating: Array(repeating: nil, count: numberCols), count: numberRows)
    }
    
    mutating func kill(_ gameObject: GameObject) {
        grid[gameObject.position.row][gameObject.position.col] = nil
        allObjects = allObjects.filter() {$0 !== gameObject}
        logger.addLog(gameObject, "is dead")
    }
    
    mutating func addGameObject(gameObject: GameObject) {
        logger.addLog(gameObject, "Added to TankLand")
        grid[gameObject.position.row][gameObject.position.col] = gameObject
        allObjects.append(gameObject)
    }
    
    mutating func populateTankWorld() {
        addGameObject(gameObject: BestTank(row: 4, col: 5, name: "JB1", energy: 100000, id: "NA", instructions: "none"))
        addGameObject(gameObject: BestTank(row: 5, col: 7, name: "JB2", energy: 100000, id: "NA", instructions: "none"))
        addGameObject(gameObject: BestTank(row: 5, col: 6, name: "JB3", energy: 100000, id: "NA", instructions: "none"))
        addGameObject(gameObject: SampleTank(row: 4, col: 6, name: "ST1", energy: 100000, id: "NA", instructions: "none"))
        addGameObject(gameObject: SampleTank(row: 5, col: 5, name: "ST2", energy: 100000, id: "NA", instructions: "none"))
        addGameObject(gameObject: SampleTank(row: 5, col: 8, name: "ST3", energy: 100000, id: "NA", instructions: "none"))
    }
}







