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
