import XCTest
import MixboxTestsFoundation

final class LastCallOfCurrentTestFileLineForFailureProviderIntegrationTests: XCTestCase {
    private func currentFileLine(file: StaticString = #file, line: UInt = #line) -> HeapFileLine {
        return HeapFileLine(
            file: "\(file)",
            line: UInt64(line)
        )
    }
    
    private var provider = LastCallOfCurrentTestFileLineForFailureProvider(
        extendedStackTraceProvider: ExtendedStackTraceProviderImpl(
            stackTraceProvider: StackTraceProviderImpl(),
            extendedStackTraceEntryFromCallStackSymbolsConverter: ExtendedStackTraceEntryFromStackTraceEntryConverterImpl()
        ),
        testSymbolPatterns: [
            ".+?\\..+?\\.test.*?\\(\\) -> \\(\\)", // XcuiTests.FailuresTests.test_multipleMatchesFailure() -> ()
            "_thePaTteRn_"
        ]
    )
    
    // MARK: - Example
    
    func test() {
        XCTAssertEqual(provider.fileLineForFailure(), currentFileLine())
    }
    
    func test_withSuffix() {
        XCTAssertEqual(provider.fileLineForFailure(), currentFileLine())
    }
    
    // MARK: - Nesting
    
    func test_whenNestedFunctionDoesntMatchTestPattern() {
        XCTAssertEqual(nested(), currentFileLine())
    }
    
    private func nested() -> HeapFileLine? {
        return provider.fileLineForFailure()
    }
    
    func test_whenDoubleNestedFunctionDoesntMatchTestPattern() {
        XCTAssertEqual(double_nested(), currentFileLine())
    }
    
    private func double_nested() -> HeapFileLine? {
        return nested()
    }
    
    // MARK: - Files
    
    func test_otherFile() {
        var actualFileLine: HeapFileLine?
        var expectedFileLine: HeapFileLine?
        let otherFile = FileForStacktraceTestsWithFixedNameAndLineNumbers {
            // Other file will be ignored
            actualFileLine = self.provider.fileLineForFailure(); expectedFileLine = self.currentFileLine()
        }
        
        otherFile.func_line2()
        
        XCTAssertNotNil(expectedFileLine)
        XCTAssertEqual(actualFileLine, expectedFileLine)
    }
    
    // MARK: - Pattern
    
    func test_whenNestedFunctionMatchesTestPattern() {
        XCTAssertEqual(provider.fileLineForFailure(), currentFileLine())
        
        thisFunctionMatchesPattern_thePaTteRn_()
        XCTAssertEqual(thisFunctionDoesntMatchPattern_thepattern_(), currentFileLine())
    }
    
    func thisFunctionMatchesPattern_thePaTteRn_() {
        XCTAssertEqual(provider.fileLineForFailure(), currentFileLine())
    }
    
    func thisFunctionDoesntMatchPattern_thepattern_() -> HeapFileLine? {
        return provider.fileLineForFailure() // should return file/line of the caller (if it is called from test function)
    }
}
