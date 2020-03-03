//
//  ItemValidation.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 22/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import Foundation
import UIKit

class ItemValidation{
    
    public func ChangeFormatDate(date : String, from: String, to: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = from
        let dateString = dateFormatter.date(from: date)
        
        dateFormatter.dateFormat = to
        return dateFormatter.string(from: dateString!)
    }
    
    public func ChangeToCurrencyFormat(_ value: String?) -> String {
        guard value != nil else { return "0" }
        let doubleValue = Double(value!) ?? 0.0
        let formatter = NumberFormatter()
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 0
        formatter.numberStyle = .currencyAccounting
        return formatter.string(from: NSNumber(value: doubleValue)) ?? "\(doubleValue)"
    }
    
    public func ChangeToCurrencyFormat(_ value: Double?) -> String {
        
        guard value != nil else { return "0" }
        let doubleValue = value!
        let formatter = NumberFormatter()
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 0
        formatter.numberStyle = .currencyAccounting
        return formatter.string(from: NSNumber(value: doubleValue)) ?? "\(doubleValue)"
    }
    
    public func StringToNSNumber(number : String) -> NSNumber{
        
        var result : NSNumber = 0
        if let resInt = Int(number) {
            result = NSNumber(value:resInt)
        }
        
        return result
    }
}

