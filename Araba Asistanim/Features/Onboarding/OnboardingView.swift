import SwiftUI

/// The first-run flow between Welcome's "Başlayalım" and sign-up, shown once
/// (gated by `hasSeenOnboarding`): three value pages that show the app instead
/// of describing it, a short personalization (goals and monthly km), a brief
/// "preparing your plan" moment, the resulting plan, and a pre-permission
/// screen for maintenance notifications. Every step can be skipped.
///
/// Always dark, on the same brand canvas as Welcome. The illustrative cards
/// use example values; nothing here is saved as vehicle data — only the
/// answers in `OnboardingPreferences`.
struct OnboardingView: View {
    let onFinished: () -> Void

    private enum Step: Int, Comparable {
        case values, personalize, preparing, summary, notifications

        static func < (lhs: Step, rhs: Step) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    @State private var step: Step = .values
    @State private var valuePage: Int? = 0
    @State private var goals: Set<OnboardingPreferences.Goal> = []
    @State private var monthlyKm = Double(OnboardingPreferences.defaultMonthlyKm)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let valuePages = ValuePage.all

    private var preferences: OnboardingPreferences {
        OnboardingPreferences(
            goals: OnboardingPreferences.Goal.allCases.filter(goals.contains),
            monthlyKm: Int(monthlyKm)
        )
    }

    private var accent: Color {
        switch step {
        case .values: return valuePages[valuePage ?? 0].accent
        case .personalize, .preparing, .summary: return AppColors.mascotViolet
        case .notifications: return AppColors.mascotIndigo
        }
    }

    var body: some View {
        ZStack {
            BrandGlowBackground(accent: accent)

            VStack(spacing: 0) {
                topBar

                Group {
                    switch step {
                    case .values: values
                    case .personalize: personalize
                    case .preparing: PreparingPlanView { go(to: .summary) }
                    case .summary: summary
                    case .notifications: notifications
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(x: reduceMotion ? 0 : 40)),
                    removal: .opacity.combined(with: .offset(x: reduceMotion ? 0 : -40))
                ))
            }
        }
        .environment(\.colorScheme, .dark)
        .toolbar(.hidden, for: .navigationBar)
        .sensoryFeedback(.selection, trigger: valuePage)
        .sensoryFeedback(.impact(weight: .light), trigger: step)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            if step > .values && step != .preparing {
                Button {
                    go(to: step == .summary ? .personalize : Step(rawValue: step.rawValue - 1) ?? .values)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: AppSizes.minTouchTarget, height: AppSizes.minTouchTarget)
                }
                .foregroundStyle(.white.opacity(0.8))
                .accessibilityLabel("Geri")
            }

            Spacer()

            if step != .preparing && step != .notifications {
                Button("Geç") {
                    finish()
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .frame(minWidth: AppSizes.minTouchTarget, minHeight: AppSizes.minTouchTarget)
            }
        }
        .frame(height: AppSizes.minTouchTarget)
        .padding(.horizontal, AppSpacing.md)
    }

    // MARK: - Value pages

    private var values: some View {
        VStack(spacing: AppSpacing.lg) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(valuePages.indices, id: \.self) { index in
                        ValuePageView(page: valuePages[index], isActive: valuePage == index)
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $valuePage)
            .scrollIndicators(.hidden)

            PageIndicator(count: valuePages.count, current: valuePage ?? 0)

            GradientPillButton(title: "Devam") {
                let current = valuePage ?? 0
                if current < valuePages.count - 1 {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85)) {
                        valuePage = current + 1
                    }
                } else {
                    go(to: .personalize)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.sm)
        }
    }

    // MARK: - Personalization

    private var personalize: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    StepHeader(
                        title: "Neler senin için önemli?",
                        message: "Birden fazla seçebilirsin. Uygulamayı buna göre hazırlayalım."
                    )

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: AppSpacing.sm), GridItem(.flexible())], spacing: AppSpacing.sm) {
                        ForEach(OnboardingPreferences.Goal.allCases) { goal in
                            GoalChip(goal: goal, isSelected: goals.contains(goal)) {
                                if goals.contains(goal) { goals.remove(goal) } else { goals.insert(goal) }
                            }
                        }
                    }
                    .sensoryFeedback(.selection, trigger: goals)

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Ayda ortalama kaç km yapıyorsun?")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.white)

                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(Int(monthlyKm).formatted(.number.locale(Locale(identifier: "en_US"))))
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                                .animation(reduceMotion ? nil : .snappy, value: monthlyKm)
                            Text("km / ay")
                                .font(.system(.title3, design: .rounded, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .foregroundStyle(.white)

                        Slider(
                            value: $monthlyKm,
                            in: Double(OnboardingPreferences.monthlyKmRange.lowerBound)...Double(OnboardingPreferences.monthlyKmRange.upperBound),
                            step: 250
                        )
                        .tint(AppColors.mascotViolet)
                        .accessibilityLabel("Aylık kilometre")
                        .accessibilityValue("\(Int(monthlyKm)) kilometre")

                        HStack {
                            Text("250")
                            Spacer()
                            Text("5,000+")
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(AppSpacing.lg)
                    .glassCard()
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)
            }
            .scrollIndicators(.hidden)

            GradientPillButton(title: "Planımı Hazırla", systemImage: "sparkles") {
                preferences.save()
                go(to: .preparing)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
        }
    }

    // MARK: - Summary

    private var summary: some View {
        let prefs = preferences
        return VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    StepHeader(title: "Planın hazır", message: "Verdiğin bilgilere göre uygulamayı şöyle ayarladık.")

                    HStack(spacing: AppSpacing.sm) {
                        SummaryStat(value: "\(prefs.monthlyKm.formattedMileage())", label: "Aylık")
                        SummaryStat(value: "~\(prefs.yearlyKm.formattedMileage())", label: "Yıllık")
                        SummaryStat(value: "~\(prefs.monthsPerOilChange) ay", label: "Yağ değişimi aralığı")
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        ForEach(prefs.goals.isEmpty ? OnboardingPreferences.Goal.allCases : prefs.goals) { goal in
                            HStack(alignment: .top, spacing: AppSpacing.sm) {
                                Image(systemName: goal.systemImage)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 34, height: 34)
                                    .background(LinearGradient.mascot(), in: Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(goal.title)
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text(goal.planLine)
                                        .font(AppTypography.footnote)
                                        .foregroundStyle(.white.opacity(0.65))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard()

                    Text("Yağ değişimi aralığı, 10,000 km veya 12 ay kuralına göre aylık kilometrenden hesaplandı. Aracını ekledikten sonra gerçek kayıtlarına göre güncellenir.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)
            }
            .scrollIndicators(.hidden)

            GradientPillButton(title: "Devam") { go(to: .notifications) }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
        }
    }

    // MARK: - Notifications

    private var notifications: some View {
        VStack(spacing: 0) {
            Spacer(minLength: AppSpacing.md)

            ZStack(alignment: .topTrailing) {
                CarMascot()
                    .frame(width: 170, height: 170)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 30))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(hex: 0xFF6B6B), .white)
                    .symbolEffect(.pulse, isActive: !reduceMotion)
                    .offset(x: 10, y: 4)
            }

            NotificationPreview()
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)

            StepHeader(
                title: "Bakımı asla kaçırma",
                message: "Bakım zamanı yaklaştığında, 3 gün önceden haber verelim. Bunun için bildirim izni gerekiyor; istediğin zaman Ayarlar'dan kapatabilirsin.",
                alignment: .center
            )
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xl)

            Spacer(minLength: AppSpacing.md)

            VStack(spacing: AppSpacing.xs) {
                GradientPillButton(title: "Bildirimlere İzin Ver", systemImage: "bell.fill") {
                    Task {
                        await MaintenanceNotificationScheduler.requestAuthorization()
                        finish()
                    }
                }
                Button("Şimdi değil") { finish() }
                    .font(.system(.headline, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .frame(maxWidth: .infinity, minHeight: AppSizes.buttonHeight)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xs)
        }
    }

    // MARK: - Navigation

    private func go(to next: Step) {
        withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.88)) {
            step = next
        }
    }

    private func finish() {
        HapticFeedback.success()
        onFinished()
    }
}

// MARK: - Value page

private struct ValuePage {
    enum Kind { case maintenance, spending, assistant }

    let kind: Kind
    let accent: Color
    let title: String
    let message: String

    static let all = [
        ValuePage(kind: .maintenance, accent: AppColors.mascotIndigo, title: "Bakım zamanını\nunutma", message: "Kilometre ve tarihe göre ne zaman ne yapılacağını önceden gör."),
        ValuePage(kind: .spending, accent: Color(hex: 0x2EC4B6), title: "Masrafların\nbir bakışta", message: "Yakıt tüketimin ve aylık giderlerin kendiliğinden hesaplansın."),
        ValuePage(kind: .assistant, accent: AppColors.mascotViolet, title: "Aklına takılanı\nsor", message: "Asistan kayıtlarına bakar, sana özel cevap verir.")
    ]
}

private struct ValuePageView: View {
    let page: ValuePage
    let isActive: Bool

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Group {
                switch page.kind {
                case .maintenance: MaintenanceVignette(isActive: isActive)
                case .spending: SpendingVignette(isActive: isActive)
                case .assistant: AssistantVignette(isActive: isActive)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                content
                    .offset(x: phase.value * 80)
                    .opacity(1 - abs(phase.value) * 0.6)
            }

            VStack(spacing: AppSpacing.xs) {
                Text(page.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.8)
                Text(page.message)
                    .font(AppTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppSpacing.xl)
            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                content
                    .offset(x: phase.value * 30)
                    .opacity(1 - abs(phase.value))
            }
        }
    }
}

/// Fades a piece in from below once `visible` turns on, staggered by `delay`.
private struct Entrance: ViewModifier {
    let visible: Bool
    var delay: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(visible || reduceMotion ? 1 : 0)
            .offset(y: visible || reduceMotion ? 0 : 28)
            .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.78).delay(delay), value: visible)
    }
}

private struct MaintenanceVignette: View {
    let isActive: Bool

    var body: some View {
        ZStack {
            reminderCard(icon: "circle.grid.cross.fill", title: "Lastik Rotasyonu", detail: "5.400 km sonra", tag: "Planlı", tone: .accent, progress: 0.3)
                .scaleEffect(0.86)
                .offset(y: -44)
                .brightness(-0.12)
                .modifier(Entrance(visible: isActive, delay: 0.16))
            reminderCard(icon: "wrench.and.screwdriver.fill", title: "Fren Kontrolü", detail: "3.100 km sonra", tag: "Planlı", tone: .accent, progress: 0.55)
                .scaleEffect(0.93)
                .offset(y: -22)
                .brightness(-0.06)
                .modifier(Entrance(visible: isActive, delay: 0.08))
            reminderCard(icon: "drop.fill", title: "Yağ Değişimi", detail: "1.200 km sonra", tag: "Yaklaşıyor", tone: .warning, progress: 0.88)
                .modifier(Entrance(visible: isActive))
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.top, 44)
    }

    private func reminderCard(icon: String, title: String, detail: String, tag: String, tone: TagView.Tone, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tone.foreground)
                    .frame(width: 44, height: 44)
                    .background(tone.background, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                    Text(detail)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer(minLength: 0)
                TagView(text: tag, tone: tone)
            }
            ProgressBar(progress: isActive ? progress : 0, tint: tone.foreground)
        }
        .padding(AppSpacing.md)
        .glassCard()
    }
}

private struct SpendingVignette: View {
    let isActive: Bool

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Label("Ort. Tüketim", systemImage: "fuelpump.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: 0x2EC4B6))
                    Text("6,8").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(.white)
                    + Text(" L/100").font(.system(.caption, design: .rounded)).foregroundStyle(.white.opacity(0.6))
                    Sparkline(points: [0.7, 0.55, 0.8, 0.5, 0.45, 0.35], tint: Color(hex: 0x2EC4B6), progress: isActive ? 1 : 0)
                        .frame(height: 34)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
                .modifier(Entrance(visible: isActive))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Label("Bu Ay", systemImage: "creditcard.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: 0x4CCB8C))
                    Text("4.250").font(.system(.title, design: .rounded, weight: .bold)).foregroundStyle(.white)
                    + Text(" TL").font(.system(.caption, design: .rounded)).foregroundStyle(.white.opacity(0.6))
                    MiniBars(values: [0.4, 0.65, 0.5, 0.9, 0.7], tint: Color(hex: 0x4CCB8C), isActive: isActive)
                        .frame(height: 34)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
                .modifier(Entrance(visible: isActive, delay: 0.08))
            }

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Kategoriye göre")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                GeometryReader { proxy in
                    HStack(spacing: 3) {
                        Capsule().fill(AppColors.mascotIndigo).frame(width: proxy.size.width * (isActive ? 0.52 : 0.02))
                        Capsule().fill(Color(hex: 0xE0A83C)).frame(width: proxy.size.width * (isActive ? 0.28 : 0.02))
                        Capsule().fill(Color(hex: 0x4CCB8C))
                    }
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: isActive)
                }
                .frame(height: 10)
                HStack(spacing: AppSpacing.md) {
                    legend("Yakıt", AppColors.mascotIndigo)
                    legend("Bakım", Color(hex: 0xE0A83C))
                    legend("Diğer", Color(hex: 0x4CCB8C))
                }
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
            .modifier(Entrance(visible: isActive, delay: 0.16))
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private func legend(_ title: String, _ color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title).font(.caption).foregroundStyle(.white.opacity(0.7))
        }
    }
}

private struct AssistantVignette: View {
    let isActive: Bool

    private let answer = "Son 3 depona göre tüketimin %6 azaldı. Bu ay en büyük giderin yakıt oldu."
    @State private var typed = ""
    @State private var isTyping = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            CarMascot()
                .frame(width: 110, height: 110)
                .padding(.bottom, AppSpacing.sm)
                .modifier(Entrance(visible: isActive))

            HStack {
                Spacer(minLength: 60)
                Text("Yakıt tüketimim nasıl gidiyor?")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(LinearGradient.mascot(startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .modifier(Entrance(visible: isActive))

            HStack(alignment: .top, spacing: AppSpacing.xs) {
                CarMascot(animates: false, glows: false)
                    .frame(width: 30, height: 30)
                    .padding(5)
                    .background(.white.opacity(0.12), in: Circle())

                Group {
                    if isTyping && typed.isEmpty {
                        TypingDots()
                    } else {
                        Text(typed.isEmpty ? " " : typed)
                            .font(AppTypography.subheadline)
                            .foregroundStyle(.white)
                    }
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: 250, alignment: .leading)
                .glassCard(cornerRadius: 20)

                Spacer(minLength: 0)
            }
            .modifier(Entrance(visible: isActive, delay: 0.2))
        }
        .padding(.horizontal, AppSpacing.lg)
        .task(id: isActive) {
            guard isActive else { typed = ""; return }
            if reduceMotion { typed = answer; return }
            isTyping = true
            typed = ""
            try? await Task.sleep(for: .milliseconds(900))
            for character in answer {
                guard !Task.isCancelled else { return }
                typed.append(character)
                try? await Task.sleep(for: .milliseconds(22))
            }
            isTyping = false
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Örnek sohbet: Yakıt tüketimim nasıl gidiyor? \(answer)")
    }
}

// MARK: - Small pieces

private struct PageIndicator: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? AnyShapeStyle(LinearGradient.mascot(startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(.white.opacity(0.25)))
                    .frame(width: index == current ? 26 : 7, height: 7)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: current)
        .accessibilityElement()
        .accessibilityLabel("Sayfa \(current + 1) / \(count)")
    }
}

private struct StepHeader: View {
    let title: String
    let message: String
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: AppSpacing.xs) {
            Text(title)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(alignment == .center ? .center : .leading)
        .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
    }
}

private struct GoalChip: View {
    let goal: OnboardingPreferences.Goal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: goal.systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(isSelected ? AnyShapeStyle(LinearGradient.mascot()) : AnyShapeStyle(.white.opacity(0.12)), in: Circle())
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.35))
                        .contentTransition(.symbolEffect(.replace))
                }
                Text(goal.title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
            .glassCard()
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(LinearGradient.mascot(), lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.appPressScale)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

private struct SummaryStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(2, reservesSpace: true)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .glassCard(cornerRadius: 18)
    }
}

private struct PreparingPlanView: View {
    let onDone: () -> Void

    private let steps = [
        "Hedeflerin kaydediliyor",
        "Bakım aralıkları hesaplanıyor",
        "Gider kategorileri ayarlanıyor",
        "Asistan hazırlanıyor"
    ]
    @State private var completed = 0

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: CGFloat(completed) / CGFloat(steps.count))
                    .stroke(LinearGradient.mascot(), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: completed)
                CarMascot(glows: false)
                    .padding(30)
            }
            .frame(width: 170, height: 170)

            Text("Planın hazırlanıyor")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                ForEach(steps.indices, id: \.self) { index in
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: index < completed ? "checkmark.circle.fill" : "circle.dotted")
                            .font(.system(size: 22))
                            .foregroundStyle(index < completed ? AnyShapeStyle(LinearGradient.mascot()) : AnyShapeStyle(.white.opacity(0.35)))
                            .contentTransition(.symbolEffect(.replace))
                        Text(steps[index])
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.white.opacity(index < completed ? 1 : 0.5))
                    }
                }
            }
            .sensoryFeedback(.success, trigger: completed)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, AppSpacing.xl)
        .task {
            for index in steps.indices {
                try? await Task.sleep(for: .milliseconds(500))
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { completed = index + 1 }
            }
            try? await Task.sleep(for: .milliseconds(450))
            onDone()
        }
    }
}

private struct NotificationPreview: View {
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image("AppLogo")
                .resizable()
                .frame(width: 34, height: 34)
                .padding(3)
                .background(LinearGradient.mascot(), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(AppBrand.name).font(.caption.weight(.semibold))
                    Spacer()
                    Text("şimdi").font(.caption2).foregroundStyle(.white.opacity(0.5))
                }
                Text("Yağ Değişimi yaklaşıyor")
                    .font(.subheadline.weight(.semibold))
                Text("Aracın için yağ değişimi zamanı 3 gün sonra.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .foregroundStyle(.white)
        .padding(AppSpacing.sm)
        .glassCard(cornerRadius: 22)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Örnek bildirim: Yağ değişimi yaklaşıyor")
    }
}

private struct ProgressBar: View {
    let progress: Double
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.12))
                Capsule().fill(tint).frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 6)
        .animation(.easeOut(duration: 0.9).delay(0.25), value: progress)
    }
}

private struct Sparkline: View {
    let points: [CGFloat]
    let tint: Color
    let progress: CGFloat

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                for (index, value) in points.enumerated() {
                    let point = CGPoint(
                        x: proxy.size.width * CGFloat(index) / CGFloat(points.count - 1),
                        y: proxy.size.height * (1 - value)
                    )
                    index == 0 ? path.move(to: point) : path.addLine(to: point)
                }
            }
            .trim(from: 0, to: progress)
            .stroke(tint, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
        .animation(.easeOut(duration: 1).delay(0.2), value: progress)
    }
}

private struct MiniBars: View {
    let values: [CGFloat]
    let tint: Color
    let isActive: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(values.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(index == values.count - 1 ? tint : .white.opacity(0.25))
                    .frame(height: 34 * (isActive ? values[index] : 0.08))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15 + Double(index) * 0.05), value: isActive)
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

private struct TypingDots: View {
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(0.7))
                    .frame(width: 7, height: 7)
                    .phaseAnimator([0.3, 1]) { content, phase in
                        content.opacity(phase)
                    } animation: { _ in
                        .easeInOut(duration: 0.45).delay(Double(index) * 0.15)
                    }
            }
        }
        .frame(height: 20)
    }
}

private extension View {
    /// Card surface on the dark brand canvas: an opaque deep-indigo fill (so
    /// stacked cards don't show through each other) with a faint top light.
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        background(
            LinearGradient(colors: [Color(hex: 0x2A2858), Color(hex: 0x1A1940)], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
}

#Preview {
    OnboardingView {}
}
