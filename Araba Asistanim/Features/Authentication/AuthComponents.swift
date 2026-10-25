import SwiftUI

/// Building blocks for the dark, brand-styled auth screens (`AuthView`,
/// `ForgotPasswordSheet`). They assume the dark brand canvas behind them.

enum AuthField: Hashable {
    case email, password, confirmPassword
}

/// A text field with a leading symbol, a label that floats up once there is
/// text or focus, a gradient focus ring, an optional show/hide eye and an
/// inline error. Return moves focus via `onSubmit`.
struct AuthTextField: View {
    let label: String
    let systemImage: String
    @Binding var text: String
    let field: AuthField
    var focus: FocusState<AuthField?>.Binding
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var submitLabel: SubmitLabel = .next
    var errorMessage: String? = nil
    var onSubmit: () -> Void = {}

    @State private var isRevealed = false

    private var isFocused: Bool { focus.wrappedValue == field }
    private var isFloating: Bool { isFocused || !text.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isFocused ? AnyShapeStyle(LinearGradient.mascot()) : AnyShapeStyle(.white.opacity(0.5)))
                    .frame(width: 22)
                    .accessibilityHidden(true)

                ZStack(alignment: .leading) {
                    Text(label)
                        .font(isFloating ? .caption.weight(.medium) : AppTypography.body)
                        .foregroundStyle(.white.opacity(isFloating ? 0.6 : 0.45))
                        .offset(y: isFloating ? -13 : 0)
                        .accessibilityHidden(true)

                    Group {
                        if isSecure && !isRevealed {
                            SecureField("", text: $text)
                        } else {
                            TextField("", text: $text)
                        }
                    }
                    .focused(focus, equals: field)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(submitLabel)
                    .onSubmit(onSubmit)
                    .font(AppTypography.body)
                    .foregroundStyle(.white)
                    .tint(AppColors.mascotViolet)
                    .offset(y: isFloating ? 8 : 0)
                    .accessibilityLabel(label)
                }

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.55))
                            .contentTransition(.symbolEffect(.replace))
                            .frame(width: 36, height: AppSizes.minTouchTarget)
                    }
                    .accessibilityLabel(isRevealed ? "Şifreyi gizle" : "Şifreyi göster")
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 58)
            .background(.white.opacity(isFocused ? 0.1 : 0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(borderStyle, lineWidth: isFocused || errorMessage != nil ? 1.6 : 1)
            )
            .contentShape(Rectangle())
            .onTapGesture { focus.wrappedValue = field }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(Color(hex: 0xFF8A8A))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFloating)
        .animation(.easeOut(duration: 0.2), value: isFocused)
        .animation(.easeOut(duration: 0.2), value: errorMessage)
        .revealsWhenFocused(id: "auth.\(label)", isFocused: isFocused)
    }

    private var borderStyle: AnyShapeStyle {
        if errorMessage != nil { return AnyShapeStyle(Color(hex: 0xFF6B6B)) }
        if isFocused { return AnyShapeStyle(LinearGradient.mascot(startPoint: .leading, endPoint: .trailing)) }
        return AnyShapeStyle(.white.opacity(0.12))
    }
}

/// The primary auth action: the mascot-gradient pill with a loading spinner.
struct AuthPrimaryButton: View {
    let title: String
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title).opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView().tint(.white)
                }
            }
            .font(.system(.headline, design: .rounded, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(LinearGradient.mascot(startPoint: .leading, endPoint: .trailing), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.18), lineWidth: 1))
            .shadow(color: AppColors.mascotViolet.opacity(0.45), radius: 16, y: 8)
        }
        .buttonStyle(.appPressScale)
        .disabled(isLoading)
        .accessibilityValue(isLoading ? "Yükleniyor" : "")
    }
}

/// "Apple ile devam et" (white, per Apple's style for dark backgrounds) and
/// "Google ile devam et" (glass, with the four-color G).
struct AuthSocialButton: View {
    enum Provider { case apple, google }

    let provider: Provider
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack(spacing: AppSpacing.xs) {
                    switch provider {
                    case .apple:
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18, weight: .medium))
                    case .google:
                        GoogleGMark()
                            .frame(width: 18, height: 18)
                    }
                    Text(provider == .apple ? "Apple ile devam et" : "Google ile devam et")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                }
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView().tint(provider == .apple ? .black : .white)
                }
            }
            .foregroundStyle(provider == .apple ? .black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                provider == .apple ? AnyShapeStyle(.white) : AnyShapeStyle(.white.opacity(0.08)),
                in: Capsule()
            )
            .overlay(Capsule().stroke(.white.opacity(provider == .apple ? 0 : 0.18), lineWidth: 1))
        }
        .buttonStyle(.appPressScale)
        .disabled(isLoading)
        .accessibilityLabel(provider == .apple ? "Apple ile devam et" : "Google ile devam et")
        .accessibilityValue(isLoading ? "Yükleniyor" : "")
    }
}

/// Google's four-color "G", drawn from arcs so no image asset is needed.
struct GoogleGMark: View {
    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let line = size * 0.2
            let radius = (size - line) / 2
            let center = CGPoint(x: size / 2, y: size / 2)

            ZStack {
                arc(center, radius, from: -40, to: 45, color: Color(hex: 0x4285F4), line: line)
                arc(center, radius, from: 45, to: 135, color: Color(hex: 0x34A853), line: line)
                arc(center, radius, from: 135, to: 205, color: Color(hex: 0xFBBC05), line: line)
                arc(center, radius, from: 205, to: 320, color: Color(hex: 0xEA4335), line: line)
                Rectangle()
                    .fill(Color(hex: 0x4285F4))
                    .frame(width: size / 2, height: line)
                    .position(x: center.x + size / 4 - line / 4, y: center.y)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private func arc(_ center: CGPoint, _ radius: CGFloat, from: Double, to: Double, color: Color, line: CGFloat) -> some View {
        Path { path in
            path.addArc(center: center, radius: radius, startAngle: .degrees(from), endAngle: .degrees(to), clockwise: false)
        }
        .stroke(color, lineWidth: line)
    }
}

/// A thin rule with a word in the middle.
struct AuthDivider: View {
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
            Text("veya").font(.footnote).foregroundStyle(.white.opacity(0.5))
            Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
        }
    }
}

/// Four-segment strength bar plus the live checklist of password rules.
struct PasswordStrengthView: View {
    let password: String

    private var satisfied: Int {
        PasswordRequirement.allCases.filter { $0.isSatisfied(by: password) }.count
    }

    private var level: (label: String, color: Color) {
        switch satisfied {
        case 0, 1: return ("Zayıf", Color(hex: 0xFF6B6B))
        case 2: return ("Orta", Color(hex: 0xE0A83C))
        case 3: return ("İyi", Color(hex: 0x8F9BFF))
        default: return ("Güçlü", Color(hex: 0x4CCB8C))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                HStack(spacing: 4) {
                    ForEach(0..<PasswordRequirement.allCases.count, id: \.self) { index in
                        Capsule()
                            .fill(index < satisfied ? level.color : .white.opacity(0.12))
                            .frame(height: 5)
                    }
                }
                Text(password.isEmpty ? " " : level.label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(level.color)
                    .frame(width: 48, alignment: .trailing)
            }

            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 6) {
                ForEach(PasswordRequirement.allCases) { requirement in
                    let isMet = requirement.isSatisfied(by: password)
                    Label(requirement.description, systemImage: isMet ? "checkmark.circle.fill" : "circle")
                        .font(.caption)
                        .foregroundStyle(isMet ? Color(hex: 0x4CCB8C) : .white.opacity(0.5))
                        .contentTransition(.symbolEffect(.replace))
                        .accessibilityLabel("\(requirement.description): \(isMet ? "karşılandı" : "karşılanmadı")")
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: satisfied)
    }
}

extension View {
    /// The frosted card that holds the auth form on the dark canvas.
    func authGlassCard() -> some View {
        background(
            LinearGradient(colors: [Color(hex: 0x2A2858).opacity(0.85), Color(hex: 0x1A1940).opacity(0.85)], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 30, y: 14)
    }

    /// A short horizontal shake, replayed whenever `trigger` changes.
    func shake(trigger: Int) -> some View {
        modifier(ShakeEffect(animatableData: CGFloat(trigger)))
            .animation(.linear(duration: 0.45), value: trigger)
    }
}

private struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(animatableData * .pi * 6), y: 0))
    }
}
