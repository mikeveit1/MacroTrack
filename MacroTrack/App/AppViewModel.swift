//
//  AppViewModel.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI

class AppViewModel: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
}
