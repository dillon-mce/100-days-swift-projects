import UIKit

var str = "Hello, playground"


extension String {
    /// remove a prefix if it exists
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    /// remove a suffix if it exists
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

print("12345".deletingPrefix("123"))
print("12345".deletingPrefix("358"))
print("12345".deletingSuffix("345"))

extension String {
    /// capitalize the first letter
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return self }
        return firstLetter.uppercased() + self.dropFirst()
    }
}

print("it sure looks like rain".capitalized)
print("it sure looks like rain".capitalizedFirst)


let input = "Swift is like Objective-C without the C"
let languages = ["Ruby", "Python", "Swift"]

print(languages.contains(where: input.contains))

let string = "This is a test string"
let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]

let attributedString1 = NSAttributedString(string: string, attributes: attributes)

let attributedString2 = NSMutableAttributedString(string: string)
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

extension String {

    /// Returns the string, ensuring that it has the given prefix
    func withPrefix(_ prefix: String) -> String {
        guard !self.hasPrefix(prefix) else { return self }
        return prefix + self
    }
}

print("pet".withPrefix("car"))
print("carpet".withPrefix("car"))

extension String {

    /// Returns true if the whole string is a number
    var isNumeric: Bool {
        return Double(self) != nil
    }

    /// Returns true if any character in the string is a number
    var hasNumeric: Bool {
        return self.contains { Double("\($0)") != nil }
    }
}

print("1.74".isNumeric)

print("OneTwo3Four".isNumeric)
print("OneTwo3Four".hasNumeric)

extension String {

    /// Returns an array of strings separated by new lines
    func lines() -> [String] {
        return self.components(separatedBy: .newlines)
    }
}

print("this\nis\na\ntest".lines())
