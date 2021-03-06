public final class ResolvedElementQuery {
    public var matchingSnapshots: [ElementSnapshot] {
        return elementQueryResolvingState.matchingSnapshots
    }
    
    // Was private before usage in logs. But there is not excuse for that.
    public var knownSnapshots: [ElementSnapshot] {
        return elementQueryResolvingState.elementSnapshots
    }
    
    private let elementQueryResolvingState: ElementQueryResolvingState
    
    public init(
        elementQueryResolvingState: ElementQueryResolvingState)
    {
        self.elementQueryResolvingState = elementQueryResolvingState
    }
    
    public func candidatesDescription() -> String? {
        guard !elementQueryResolvingState.matchingResults.isEmpty else {
            return nil
        }
        
        let sortedResults = elementQueryResolvingState.matchingResults.enumerated().sorted { left, right -> Bool in
            left.element.percentageOfMatching > right.element.percentageOfMatching // по убыванию соответствия
        }
        
        var lines = [String]()
        for (index, result) in sortedResults {
            switch result {
            case .match:
                lines.append("Снепшот \(index), полное соответствие:")
                let snapshotDescription = elementQueryResolvingState.elementSnapshots[index].debugDescription
                lines.append(snapshotDescription.mb_indent("    "))
            case .mismatch(let percentage, let description):
                lines.append("Снепшот \(index), соответствие \(percentage):")
                lines.append(description())
            }
        }
        return lines.joined(separator: "\n")
    }
}
