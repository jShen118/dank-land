//
//  Game Objects.swift
//  TankLand
//
//  Created by Joshua Shen on 5/7/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation

//GAME OBJECTS
enum GameObjectType {
    case GameObject, Tank, Mine, Rover
}

class GameObject: CustomStringConvertible {
    var name: String
    private (set) var energy: Int
    let objectType: GameObjectType
    let id: String
    var position: Position
    
    init(row: Int, col: Int, objectType: GameObjectType, name: String, energy: Int, id: String) {
        self.objectType = objectType
        self.name = name
        self.energy = energy
        self.id = id
        self.position = Position(row, col)
    }
    
    var description: String {
        return " \n \n "
    }
    
    func applyCost(_ amount: Int) {
        energy = energy - amount
    }
}

class Tank: GameObject {
    private (set) var shields: Int = 0
    private (set) var radarResults: [RadarResult]?
    private var receivedMessage: String?
    private (set) var preActions = [Actions: PreAction]()
    private (set) var postActions = [Actions: PostAction]()
    private let initialInstructions: String?
    
    init(row: Int, col: Int, name: String, energy: Int, id: String, instructions: String) {
        initialInstructions = instructions
        super.init(row: row, col: col, objectType: .Tank, name: name, energy: energy, id: id)
    }
    
    func setReceivedMessage(receivedMessage: String!) {
        self.receivedMessage = receivedMessage
    }
    
    final func setRadarResult(radarResults: [RadarResult]!) {
        self.radarResults = radarResults
    }
    
    func setShield(amount: Int) {
        shields = amount
    }
    
    final func addPreAction(preAction: PreAction) {
        preActions[preAction.action] = preAction
    }
    
    final func addPostAction(postAction: PostAction) {
        postActions[postAction.action] = postAction
    }
    
    final func clearActions() {
        preActions = [Actions: PreAction]()
        postActions = [Actions: PostAction]()
    }
    
    func computePreActions() {}
    func computePostActions() {}
    
    override var description: String {
        return "\(name)\n\(energy)"
    }
}

class Mine: GameObject{
    var mineNumber: Int
    var moveDirection: Direction?
    static var numberMines = 0
    var isRover: Bool
    
    init(row: Int, col: Int, energy: Int, isRover: Bool, moveDirection: Direction? = nil) {
        self.isRover = isRover
        self.moveDirection = moveDirection
        mineNumber = Mine.numberMines
        Mine.numberMines += 1
        super.init(row: row, col: col, objectType: .Mine, name: "Mine #\(String(mineNumber))", energy: energy, id: "mine")
    }
}

struct Position: CustomStringConvertible {
    var row: Int
    var col: Int
    init(_ row: Int, _ col: Int){
        self.row = row
        self.col = col
    }
    var description: String{
        return "(\(row),\(col))"
    }
}
