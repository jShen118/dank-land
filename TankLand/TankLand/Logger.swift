//
//  Logger.swift
//  TankLand
//
//  Created by Joshua Shen on 5/12/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation
//Logger
struct Logger {
    var turn = 0
    let timeStamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
    func addLog(_ gameObject: GameObject, _ string: String) {
        print("\(turn) \(timeStamp) \(gameObject.objectType) \(gameObject.name) \(gameObject.position) \(string)")
    }
}
