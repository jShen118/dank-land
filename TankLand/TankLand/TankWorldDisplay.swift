//
//  TankWorldDisplay.swift
//  TankLand
//
//  Created by Joshua Shen on 5/12/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation
//TankWorld Display
extension TankWorld {
    func eightSpaceFit(word: String)-> String {
        let spaces = String(repeating: " ", count: (8 - word.count))
        return "\(spaces)\(word)|"
    }
    
    func gridReport() {
        var result = ""
        for _ in 0..<numberCols {
            result += "_________"
        }
        result += "_"
        
        var rows = [String]()
        for row in 0..<numberRows {
            var firstLine = "|"
            var secondLine = "|"
            var thirdLine = "|"
            var fourthLine = "|"
            for _ in 0..<numberCols {
                fourthLine += "________|"
            }
            for col in 0..<numberCols {
                if grid[row][col] != nil {
                    firstLine += eightSpaceFit(word: String(grid[row][col]!.energy))
                    secondLine += eightSpaceFit(word: String(grid[row][col]!.name))
                    thirdLine += eightSpaceFit(word: String(describing: grid[row][col]!.position))
                }
                else {
                    firstLine += "        |"
                    secondLine += "        |"
                    thirdLine += "        |"
                }
            }
            rows.append("\n\(firstLine)\n\(secondLine)\n\(thirdLine)\n\(fourthLine)")
        }
        
        for r in rows.reversed() {
            result += r
        }
        print(result)
    }
}
