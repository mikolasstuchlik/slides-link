//
//  LinkSlidesApp.swift
//  LinkSlides
//
//  Created by Mikoláš Stuchlík on 20.08.2022.
//

import SwiftUI

@main
struct LinkSlidesApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            LinkSlides().environmentObject(PresentationProperties.shared)
        }
    }
}
