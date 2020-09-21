//
//  TankAI.swift
//  TankLand
//
//  Created by Joshua Shen on 6/8/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//
//Tank AI
import Foundation

class BestTank: Tank {
    override init(row: Int, col: Int, name: String, energy: Int, id: String, instructions: String) {
        super.init(row: row, col: col, name: name, energy: energy, id: id, instructions: instructions)
    }
    
    func chanceOf(percent: Int)-> Bool {
        let ran = getRandomInt(range: 100)
        return percent <= ran
    }
    
    func senseDanger(data: [RadarResult])-> Bool {
        var count = 0
        for _ in data {count += 1}
        if count > 0 {return true}
        return false
    }
    
    func atCorner()-> Bool {
        if (position.row == 0 || position.row == 14) && (position.col == 0 || position.col == 14) {return true}
        return false
    }
    
    func findNearestCorner()-> Position {
        let corners = [Position(0, 0), Position(0, 14), Position(14, 0), Position(14, 14)]
        var nearest = 100.0
        var result = Position(0, 0)
        for c in corners {
            if distanceHelper(self.position, c) < nearest {
                result = c
                nearest = distanceHelper(self.position, c)
            }
        }
        return result
    }
    
    func moveTowardsCorner(corner: Position)-> MoveAction {
        if position.row < corner.row {return MoveAction(direction: .North, distance: 1)}
        if position.row > corner.row {return MoveAction(direction: .South, distance: 1)}
        if position.col < corner.col {return MoveAction(direction: .East, distance: 1)}
        if position.col > corner.col {return MoveAction(direction: .West, distance: 1)}
        return MoveAction(direction: .North, distance: 0)
    }
    
    func oppositeCornerDirection()-> Direction {
        if position.row == 0 && position.col == 0 {return .Northeast}
        if position.row == 0 && position.col == 14 {return .Northwest}
        if position.row == 14 && position.col == 0 {return .Southeast}
        if position.row == 14 && position.col == 14 {return .Southwest}
        return .North
    }
    
    func nearestObject()-> Position {
        var nearest = (0.0, Position(0, 0))
        var oldnearest = (100.0, Position(0, 0))
        for r in radarResults! {
            if distanceHelper(self.position, r.position) < oldnearest.0 && getEnergyFromRadarResultsAndPosition(radarResults!, r.position) > 800 {
                nearest = (distanceHelper(self.position, r.position), r.position)
                oldnearest = nearest
            }
        }
        return nearest.1
    }
    
    func powerToKill(_ energy: Int)-> Int {
        return (energy / 10) + 1
    }
    
    func getEnergyFromRadarResultsAndPosition(_ radarResults: [RadarResult], _ position: Position)-> Int {
        for r in radarResults {
            if position.row == r.position.row && position.col == r.position.col {return r.energy}
        }
        return 801
    }
    
    override func computePreActions() {
        if chanceOf(percent: 50) {addPreAction(preAction: RadarAction(radius: 3))} else {addPreAction(preAction: RadarAction(radius: 5))}
        if radarResults != nil {if senseDanger(data: radarResults!) {addPreAction(preAction: ShieldAction(power: 300))}}
    }
    
    override func computePostActions() {
        if atCorner() {addPostAction(postAction: DropMineAction(power: 800, isRover: true, dropDirection: oppositeCornerDirection(), moveDirection: oppositeCornerDirection()))}
        if radarResults != nil && distanceHelper(nearestObject(), position) >= 2.0 {
            addPostAction(postAction: MissileAction(power: powerToKill(getEnergyFromRadarResultsAndPosition(radarResults!, nearestObject())), target: nearestObject()))
        }
        if !atCorner() {addPostAction(postAction: moveTowardsCorner(corner: findNearestCorner()))}
    }
}


class SampleTank: Tank {
    override init(row: Int, col: Int, name: String, energy: Int, id: String, instructions: String) {
        super.init(row: row, col: col, name: name, energy: energy, id: id, instructions: instructions)
    }
    
    func chanceOf(percent: Int)-> Bool {
        let ran = getRandomInt(range: 100)
        return percent <= ran
    }
    
    override func computePreActions() {
        addPreAction(preAction: ShieldAction(power: 300))
        addPreAction(preAction: RadarAction(radius: 4))
        //super.computePreActions()
    }
    
    override func computePostActions() {
        if chanceOf(percent: 50) {
            let randomDirection = getRandomDirection()
            addPostAction(postAction: MoveAction(direction: randomDirection, distance: 2))
        }
        guard let rs = radarResults, rs.count != 0 else {return}
        if energy < 5000 {return}
        
        if chanceOf(percent: 50) {return}
        let randomItem = rs[getRandomInt(range: rs.count)]
        let missileEnergy = energy > 2000 ? 1000: (energy / 20)
        addPostAction(postAction: MissileAction(power: missileEnergy, target: randomItem.position))
        super.computePostActions()
    }
}




