import SwiftUI

/// A large, prominent currency input — the visual focal point of the Add
/// Expense form. Bound directly to a raw digit/decimal-point string (kept
/// sanitized as the user types) so the keyboard's own cursor handling is
/// never fought with a reformat-per-keystroke trick.
struct AmountField: View {
    @Binding var text: String
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Tutar")
                .font(AppTypography.footnote)
                .foregroundStyle(AppTheme.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("₺")
                    .font(AppTypography.title2)
                    .foregroundStyle(isFocused ? AppTheme.primary : AppTheme.textSecondary)

                TextField("0.00", text: $text)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onChange(of: text) { _, newValue in
                        let sanitized = Self.sanitize(newValue)
                        if sanitized != newValue {
                            text = sanitized
                        }
                    }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .stroke(borderColor, lineWidth: isFocused || errorMessage != nil ? 1.5 : 0)
            )

            if let errorMessage {
                ErrorView(message: errorMessage)
            }
        }
        .animation(AppAnimation.fast, value: errorMessage)
    }

    private var borderColor: Color {
        errorMessage != nil ? AppTheme.error : AppTheme.primary
    }

    /// Keeps only digits and at most one decimal point, capped at two
    /// fractional digits.
    private static func sanitize(_ input: String) -> String {
        var result = ""
        var hasDecimal = false
        var decimalDigits = 0
        for char in input {
            if char.isNumber {
                if hasDecimal {
                    guard decimalDigits < 2 else { continue }
                    decimalDigits += 1
                }
                result.append(char)
            } else if char == "." && !hasDecimal {
                hasDecimal = true
                result.append(char)
            }
        }
        return result
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        AmountField(text: .constant(""))
        AmountField(text: .constant("1250.5"))
        AmountField(text: .constant(""), errorMessage: "Geçerli bir tutar gir.")
    }
    .padding()
}
