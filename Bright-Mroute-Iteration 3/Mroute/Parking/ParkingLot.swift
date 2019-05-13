//
//  File.swift
//  Mroute
//
//  Created by zhongheng on 27/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.

// The NSobject viewController that will store the data from database into the ParkingLot object, with different variables.

import Foundation

class ParkingLot: NSObject {
    var longitude: Double?
    var latitude: Double?
    var bayId: Int64?
    var timeDuration: Int?
    var parkingDuration: String?
    var payment: String?
    var streetMarkerId: String?
    var time: String?
    var status: String?
    var days: String?
    
    init(longitude: Double?, latitude: Double?, bayID: Int64?, timeduration: Int?, duration: String?, payType: String?, streetID: String?, parkTime: String?, status: String?, days:String?) {
        self.longitude = longitude
        self.latitude = latitude
        bayId = bayID
        timeDuration = timeduration
        parkingDuration = duration
        payment = payType
        streetMarkerId = streetID
        time = parkTime
        self.status = status
        self.days = days
    }
}
