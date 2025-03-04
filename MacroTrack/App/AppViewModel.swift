//
//  AppViewModel.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/4/25.
//

import Foundation
import SwiftUI

class AppViewModel: ObservableObject {
    // Global app-wide login state using @AppStorage for persistence
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
}
