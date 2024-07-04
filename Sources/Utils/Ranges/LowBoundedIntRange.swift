public protocol LowBoundedIntRange: Sequence {
    var count: Int { get }
    var lowerBound: Int { get }
}

extension Range: LowBoundedIntRange where Bound == Int {}

extension ClosedRange: LowBoundedIntRange where Bound == Int {}
