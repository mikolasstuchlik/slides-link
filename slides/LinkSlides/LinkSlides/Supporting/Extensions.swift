
extension ClosedRange where Bound: BinaryFloatingPoint {
    init<Other: BinaryFloatingPoint>(_ other: ClosedRange<Other>) {
        self = Bound(other.lowerBound)...Bound(other.upperBound)
    }
    
    init<Other: BinaryInteger>(_ other: ClosedRange<Other>) {
        self = Bound(other.lowerBound)...Bound(other.upperBound)
    }
}
