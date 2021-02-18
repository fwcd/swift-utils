import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CircularArrayTests.allTests),
        testCase(ComplexTests.allTests),
        testCase(TokenIteratorTests.allTests),
        testCase(CollectionUtilsTests.allTests),
        testCase(StringUtilsTests.allTests),
        testCase(MathUtilsTests.allTests),
        testCase(BinaryHeapTests.allTests),
        testCase(StablePriorityQueueTests.allTests),
        testCase(Mat2Tests.allTests),
        testCase(RationalTests.allTests),
        testCase(NDArrayTests.allTests),
        testCase(MatrixTests.allTests),
        testCase(BiDictionaryTests.allTests)
    ]
}
#endif
