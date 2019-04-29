//
//  Toilets.swift
//  Mroute
//
//  Created by Zhongheng Hu on 4/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.

//  Object class that save HookTurn

import Foundation

class HookTurn : NSObject {
    var name: String?
    var longitude: Double?
    var latitude: Double?
    
    init(name: String?, longitude: Double?, latitude: Double?) {
        self.name = name;
        self.longitude = longitude
        self.latitude = latitude
    }
}
