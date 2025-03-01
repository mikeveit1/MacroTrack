//
//  ApplicationHelper.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/1/25.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        windows.first?.endEditing(true)
    }
}
