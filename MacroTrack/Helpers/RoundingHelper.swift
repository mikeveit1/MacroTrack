//
//  RoundingHelper.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/1/25.
//

import Foundation


extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
