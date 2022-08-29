import SwiftUI

struct SwiftShrnuti: View, Slide {
    // @offset(SwiftShrnuti)
    static var offset = CGVector(dx: 0, dy: 0)
    
    // @hint(SwiftShrnuti){
    static var hint: String? =
"""
... proces sestavování je poněkud komplikovanější
- Všimněte si, že končí vygenerováním souborů `.o`
- Poté to převezme Linker editor

**Swift nemá preprocesor**
 - Focus (Všimněte si, že kompilátor Swift akceptuje i hlavičkové soubory `.h`)
 - Swift hlavičkové soubory `.h` nemá
 - Focus (místo toho používá soubory `.swiftmodule`)

Nejdřív si ukážeme, co jsou soubory `.swiftmldule` a `.swiftdoc`, potom si ukážeme použití statické a dynamické knihovny

"""
    // }@hint(SwiftShrnuti)
    
    init() {}

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Swift").font(.presentationHeadline)
                Text("Shrnutí procesu kompilace").font(.presentationSubHeadline)
            }.frame(maxWidth: .infinity, alignment: .leading)
            Image("swiftc").resizable().scaledToFit()
        }.padding()
    }
}

struct SwiftShrnuti_Previews: PreviewProvider {
    static var previews: some View {
        SwiftShrnuti().frame(width: 1024, height: 768)
    }
}
