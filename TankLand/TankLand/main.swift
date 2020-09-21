//
//  main.swift
//  TankLand
//
//  Created by Joshua Shen on 4/7/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

//TEST CODE
var tankWorld = TankWorld(numberRows: 15, numberCols: 15)
tankWorld.populateTankWorld()
print(tankWorld.gridReport())
for _ in 0..<20 {
    tankWorld.runOneTurn()
}




