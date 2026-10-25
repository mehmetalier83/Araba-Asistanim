import SwiftUI

/// A ScrollView for data-entry forms that scrolls whichever field gains focus
/// into view, so the keyboard (plus its "Bitti" bar) never hides the field
/// being edited — e.g. Kilometre at the bottom of the fuel form.
/// Fields opt in by calling `revealsWhenFocused(id:isFocused:)`.
struct FormScrollView<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                content
            }
            .environment(\.revealFocusedField) { id in
                withAnimation(AppAnimation.fast) {
                    proxy.scrollTo(id, anchor: .center)
                }
            }
        }
    }
}

private struct RevealFocusedFieldKey: EnvironmentKey {
    static let defaultValue: ((String) -> Void)? = nil
}

extension EnvironmentValues {
    var revealFocusedField: ((String) -> Void)? {
        get { self[RevealFocusedFieldKey.self] }
        set { self[RevealFocusedFieldKey.self] = newValue }
    }
}

private struct RevealWhenFocused: ViewModifier {
    let id: String
    let isFocused: Bool
    @Environment(\.revealFocusedField) private var reveal

    func body(content: Content) -> some View {
        content
            .id(id)
            .onChange(of: isFocused) {
                guard isFocused, let reveal else { return }
                Task {
                    // Wait for the keyboard to finish appearing first.
                    try? await Task.sleep(for: .milliseconds(350))
                    reveal(id)
                }
            }
    }
}

extension View {
    func revealsWhenFocused(id: String, isFocused: Bool) -> some View {
        modifier(RevealWhenFocused(id: id, isFocused: isFocused))
    }
}
