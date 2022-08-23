//
//  SwiftBackground.swift
//  LinkSlides
//
//  Created by Mikoláš Stuchlík on 23.08.2022.
//

import SwiftUI

struct SwiftBackground: View, Background {
    static var offset: CGVector = CGVector(dx: -2, dy: 2)
    static var relativeSize: CGSize = CGSize(width: 2, height: 2)
    
    var body: some View {
        Image("swift").colorInvert().scaledToFill()
    }
}

struct SwiftBackground_Previews: PreviewProvider {
    static var previews: some View {
        SwiftBackground()
    }
}
