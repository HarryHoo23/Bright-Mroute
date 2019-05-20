//
//  Facility.swift
//  Mroute
//
//  Created by zhongheng on 8/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.

//  Object class that save Facility, accessible spots.

import Foundation

class Facility: NSObject {
    var name: String?
    var assetType: String?
    var longitude: Double?
    var latitude: Double?
    
    init(name: String?, type: String?, longitude: Double?, latitude: Double?) {
        self.name = name;
        self.assetType = type
        self.longitude = longitude
        self.latitude = latitude
    }
}
