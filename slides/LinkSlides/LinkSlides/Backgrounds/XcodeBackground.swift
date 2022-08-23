//
//  XcodeBackground.swift
//  LinkSlides
//
//  Created by Mikoláš Stuchlík on 23.08.2022.
//

import SwiftUI

struct XcodeBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 0, dy: -2)
    static var relativeSize: CGSize = CGSize(width: 4, height: 4)
    
    var body: some View {
        Image("xc")
            .scaledToFit()
    }
}

struct XcodeBackground_Previews: PreviewProvider {
    static var previews: some View {
        XcodeBackground()
    }
}
