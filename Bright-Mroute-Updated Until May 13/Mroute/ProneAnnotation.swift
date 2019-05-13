//
//  ProneAnnotation.swift
//  Mroute
//
//  Created by zhongheng on 13/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import Foundation
import MapKit

class ProneAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var information: String?
    
    init(newTitle: String, subtitle: String, level: String,
    location: CLLocationCoordinate2D) {
        self.title = newTitle
        self.subtitle = subtitle
        self.information = level
        self.coordinate = location
    }
    
    
}
