//
//  ProneZone.swift
//  Mroute
//
//  Created by zhongheng on 4/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//
//This class is the object class of pronezone, that when I connect the dataset, it can be saved into object
// arrayList.

import Foundation
import MapKit

class ProneZone: NSObject{
    // define the useful attributes
    var imageName: String?
    var title: String?
    var longitude: Double?
    var latitude: Double?
    var speedZone: String?
    var criticalLevel: String?
    var frequency: Int?
    
    init(title: String, longtitude: Double, latitude: Double, speed: String, critical: String, frequency: Int){
        self.title = title
        self.longitude = longtitude
        self.latitude = latitude
        self.speedZone = speed
        criticalLevel = critical
        self.frequency = frequency
    }
    
}
