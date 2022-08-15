import Foundation

/// My great struct.
public struct FooHello {

    public internal(set) var name: String

    public init(name: String) { self.name = name }

    /// My greet function
    /// - Parameter add: Add new person to greet
    public mutating func greet(and add: String? = nil) {
        if let add = add {
            name += " and \(add)"
        }

        print("Hello \(name)")
    }

    /// Private documentation.
    func hiddenGreet() {
        print("Hello \(name) <3")
    }

}

/*
 swiftc -parse-as-library -emit-library -emit-module -static FooLib.swift

 Obrázek: https://qiita.com/rintaro/items/3ad640e3938207218c20


.swiftmodule:
 xcrun swift-api-digester -dump-sdk -module FooLib -o foo -I`pwd`
 nebo
 sourcekitten module-info --module FooLib -- -sdk "$(xcrun --show-sdk-platform-path)/Developer/SDKs/MacOSX$(xcrun --show-sdk-version).sdk" -I`pwd`

 */
