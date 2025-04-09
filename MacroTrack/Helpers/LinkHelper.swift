//
//  LinkHelper.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/6/25.
//

import Foundation

class LinkHelper {
    func getTermsLink(completion: @escaping (String) -> Void) {
        FirebaseService.shared.getLink(linkName: "terms") { link in
            let linkString = link
            completion(linkString)
        }
    }
    
    func getPrivacyPolicyLink(completion: @escaping (String) -> Void) {
        FirebaseService.shared.getLink(linkName: "privacyPolicy") { link in
            let linkString = link
            completion(linkString)
        }
    }
    
    func getContactUsLink(completion: @escaping (String) -> Void) {
        FirebaseService.shared.getLink(linkName: "contactUs") { link in
            let linkString = link
            completion(linkString)
        }
    }
    
}
