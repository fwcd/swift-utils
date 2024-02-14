import RegexBuilder

extension ChoiceOf where RegexOutput == Substring {
    /// Constructs a choice from the given sequence.
    ///
    /// Credit: https://stackoverflow.com/a/73916264
    init<S>(nonEmptyComponents: S) where S: Sequence<String> {
        let expressions = nonEmptyComponents.map { AlternationBuilder.buildExpression($0) }

        guard !expressions.isEmpty else {
            fatalError("Cannot construct an empty ChoiceOf!")
        }

        self = expressions.dropFirst().reduce(AlternationBuilder.buildPartialBlock(first: expressions[0])) { acc, next in
            AlternationBuilder.buildPartialBlock(accumulated: acc, next: next)
        }
    }
}
