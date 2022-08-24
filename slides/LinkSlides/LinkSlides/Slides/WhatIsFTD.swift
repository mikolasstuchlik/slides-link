import SwiftUI

struct WhatIsFTD: View, Slide {
    static let offset = CGVector(dx: 1, dy: 0)

    init() {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Jak spustit prezentaci")
                .font(.presentationHeadline)
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
            .font(.presentationBody)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding()
    }
}


struct WhatIsFTD_Previews: PreviewProvider {
    static var previews: some View {
        WhatIsFTD()
    }
}
