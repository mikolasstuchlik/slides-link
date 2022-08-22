import SwiftUI

struct WhatIsFTD: View, Slide {
    static let offset = CGVector(dx: 1, dy: 0)

    var body: some View {
        ZStack {
            Color.white
            VStack(alignment: .leading, spacing: 16) {
                Text("Jak spustit prezentaci")
                    .foregroundColor(.black)
                    .font(.system(size: 40))
                    .bold()
                Text(
"""
**Spuštění na macOS**
 - Stáhněte
 - Otevřete v Xcode
 - Ověřte, že je smazaný sandbox
 - Klávesa `cmd + enter` dává salší slide
 - Klávesa `cmd + p` dává předchozí slide
 - Zkuste změnit velikost okna :O
 
**Můžete si prohlédnout ale i více slidů zároveň!!!**
"""
                )
                .foregroundColor(.black)
                .font(.system(size: 24))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding()
        }
    }
}


struct WhatIsFTD_Previews: PreviewProvider {
    static var previews: some View {
        WhatIsFTD()
    }
}
