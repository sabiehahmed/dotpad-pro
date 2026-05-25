import UIKit

/// Live Markdown highlighting for plain-text dots — Tot's "Add color
/// highlights to text". Re-applies attributes over the whole storage; only
/// used in plain mode where the document is treated as Markdown.
enum MarkdownHighlighter {

    private static let heading = try! NSRegularExpression(pattern: "^(#{1,6})\\s+.*$", options: [.anchorsMatchLines])
    private static let bold = try! NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*")
    private static let link = try! NSRegularExpression(pattern: "https?://[^\\s]+")

    static func apply(
        to storage: NSTextStorage,
        baseFont: UIFont,
        baseColor: UIColor,
        accent: UIColor,
        linkColor: UIColor,
        enabled: Bool
    ) {
        let full = NSRange(location: 0, length: storage.length)
        storage.beginEditing()
        storage.setAttributes([.font: baseFont, .foregroundColor: baseColor], range: full)

        if enabled {
            let text = storage.string
            let ns = text as NSString
            let range = NSRange(location: 0, length: ns.length)
            let headingFont = UIFont.systemFont(ofSize: baseFont.pointSize, weight: .semibold)
            let boldFont = UIFont.boldSystemFont(ofSize: baseFont.pointSize)

            heading.enumerateMatches(in: text, range: range) { m, _, _ in
                guard let r = m?.range else { return }
                storage.addAttributes([.foregroundColor: accent, .font: headingFont], range: r)
            }
            bold.enumerateMatches(in: text, range: range) { m, _, _ in
                guard let r = m?.range else { return }
                storage.addAttribute(.font, value: boldFont, range: r)
            }
            link.enumerateMatches(in: text, range: range) { m, _, _ in
                guard let r = m?.range else { return }
                storage.addAttributes([.foregroundColor: linkColor, .underlineStyle: NSUnderlineStyle.single.rawValue], range: r)
            }
        }
        storage.endEditing()
    }
}
