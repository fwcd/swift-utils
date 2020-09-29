import Foundation

fileprivate let asciiCharacters = CharacterSet(charactersIn: " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
fileprivate let quotes = CharacterSet(charactersIn: "\"'`")
fileprivate let markdownEscapable = try! Regex(from: "[\\[\\]*_]")

extension StringProtocol {
    public var withFirstUppercased: String {
        prefix(1).uppercased() + dropFirst()
    }

    public var markdownEscaped: String {
        markdownEscapable.replace(in: String(self)) { "\\\($0[0])" }
    }

    public var camelHumps: [String] {
        var humps = [String]()
        var hump = ""

        for c in self {
            if c.isUppercase && hump.count > 1 {
                humps.append(hump)
                hump = String(c)
            } else {
                hump.append(c)
            }
        }

        if !hump.isEmpty {
            humps.append(hump)
        }

        return humps
    }

    public var camelHumpsWithUnderscores: [String] {
        camelHumps.flatMap { $0.split(separator: "_") }.map(String.init)
    }

    public func split(by length: Int) -> [String] {
        var start = startIndex
        var output = [String]()

        while start < endIndex {
            let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
            output.append(String(self[start..<end]))
            start = end
        }

        return output
    }

    public func splitPreservingQuotes(by separator: Character, omitQuotes: Bool = false, omitBackslashes: Bool = false) -> [String] {
        var split = [String]()
        var segment = ""
        var quoteStack = [Character]()
        var last: Character? = nil
        for c in self {
            if quoteStack.isEmpty && c == separator {
                split.append(segment)
                segment = ""
            } else {
                let isQuote = c.unicodeScalars.first.map { quotes.contains($0) } ?? false
                let isEscaped = last == "\\"

                if isQuote && !isEscaped {
                    if let quote = quoteStack.last, quote == c {
                        quoteStack.removeLast()
                    } else {
                        quoteStack.append(c)
                    }
                }

                if isQuote && isEscaped && omitBackslashes {
                    segment.removeLast()
                }

                if !omitQuotes || !isQuote || isEscaped {
                    segment.append(c)
                }
            }
            last = c
        }
        split.append(segment)
        return split
    }

    public var asciiOnly: String? {
        return components(separatedBy: asciiCharacters).joined()
    }

    public var nilIfEmpty: Self? {
        return isEmpty ? nil : self
    }

    public var isAlphabetic: Bool {
        for scalar in unicodeScalars {
            if !CharacterSet.letters.contains(scalar) {
                return false
            }
        }
        return true
    }

    public func truncate(_ length: Int, appending trailing: String = "") -> String {
        if count > length {
            return prefix(length) + trailing
        } else {
            return String(self)
        }
    }

    public func pluralize(with value: Int) -> String {
        value == 1 ? String(self) : "\(self)s"
    }

    public func levenshteinDistance<S>(to rhs: S, caseSensitive: Bool = true) -> Int where S: StringProtocol {
        let width = count + 1
        let height = rhs.count + 1
        var matrix = [Int](repeating: 0, count: width * height)
        let (lhsChars, rhsChars) = caseSensitive
            ? (Array(self), Array(rhs))
            : (Array(lowercased()), Array(rhs.lowercased()))

        for i in 0..<width {
            matrix[i] = i
        }
        for i in 0..<height {
            matrix[i * width] = i
        }

        for y in 1..<height {
            for x in 1..<width {
                let equal = lhsChars[x - 1] == rhsChars[y - 1]
                matrix[y * width + x] = [
                    matrix[(y - 1) * width + (x - 1)] + (equal ? 0 : 1),
                    matrix[(y - 1) * width + x] + 1,
                    matrix[y * width + (x - 1)] + 1
                ].min()!
            }
        }

        return matrix.last!
    }

    /// Applies this string as a 'template' containing % placeholders to a list of arguments
    public func applyAsTemplate(to args: [String]) -> String {
        var result = ""
        var argIterator = args.makeIterator()
        for c in self {
            if c == "%" {
                guard let arg = argIterator.next() else { fatalError("Provided too few args to apply(template:to:)!") }
                result += arg
            } else {
                result.append(c)
            }
        }
        return result
    }
}
