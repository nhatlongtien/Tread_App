//
//  HelperMethod.swift
//  Treads
//
//  Created by NGUYENLONGTIEN on 6/8/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import Foundation

extension Int{
    func convertFromDurationTimeToTime() -> String{
        var durationHours = self/3600
        var durationMinutes = (self%3600)/60
        var durationSeconds = (self%3600)%60
        if durationSeconds < 0{
            return "00:00:00"
        }else{
            return String(format: "%02d:%02d:%02d", durationHours,durationMinutes,durationSeconds)
        }
    }
}
