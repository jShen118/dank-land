//
//  RadarResult.swift
//  TankLand
//
//  Created by Joshua Shen on 5/11/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation
//RadarResult
struct RadarResult: CustomStringConvertible {
    let position: Position
    let id: String
    let energy: Int
    
    init(position: Position, id: String, energy: Int) {
        self.position = position
        self.id = id
        self.energy = energy
    }
    
    var description: String {
        return "Position \(position), ID \(id), \(energy) energy"
    }
}
