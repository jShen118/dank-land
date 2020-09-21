//
//  Constants.swift
//  TankLand
//
//  Created by Joshua Shen on 5/11/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation
//Constants
struct Constants {
    static let costOfRadarPerUnitsDistance = [0, 100, 200, 400, 800, 1600, 3200, 6400, 12400]
    static let initialTankEnergy = 100000
    static let SendingMessage = 100
    static let ReceivingMessage = 100
    static let costOfReleasingMine = 250
    static let costOfReleasingRover = 500
    static let costOfLaunchingMissile = 1000
    static let costOfFlyingMissilePerUnitDistance = 200
    static let costOfMovingTankPerUnitDistance = [100, 300, 600]
    static let costOfMovingRover = 50
    static let costLifeSupportTank = 100
    static let costLifeSupportRover = 40
    static let costLifeSupportMine = 20
    static let missileStrikeMultiple = 10
    static let missileStrikeMultipleCollateral = 3
    static let mineStrikeMultiple = 5
    static let shieldPowerMultiple = 8
    static let missileStrikeEnergyTransferFraction = 4
}
