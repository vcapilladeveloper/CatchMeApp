//
//  DatesHelper.swift
//  CatchMeApp
//
//  Created by Victor Capilla Developer on 14/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation

// Helper for manage the dates
final public class DateHelper {
    
    
    /// Format a date and return in String Fromat
    ///
    /// - Parameter date: Date what we want to convert in String and formatted
    /// - Returns: String with the formatted string like Sat, 10 of december 2019
    public class func giveMeTodayDate(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, dd MMMM yyyy"
        return dateFormatter.string(from: Date())
        
    }
}
