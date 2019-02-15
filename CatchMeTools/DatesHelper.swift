//
//  DatesHelper.swift
//  CatchMeApp
//
//  Created by Victor Capilla Developer on 14/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation

final class DateHelper {
    class func giveMeTodayDate(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, dd MMMM yyyy"
        return dateFormatter.string(from: Date())
        
    }
}
