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
        ZStack {
            LinearGradient(
                colors: [.init(red: 233.0/255.0, green: 100.0/255.0, blue: 50.0/255.0), .init(red: 240.0/255.0, green: 140.0/255.0, blue: 40.0/255.0)],
                startPoint: .bottom,
                endPoint: .top
            )
            Image("swift").colorInvert()
        }.cornerRadius(40)
    }
}

struct SwiftBackground_Previews: PreviewProvider {
    static var previews: some View {
        SwiftBackground()
    }
}
