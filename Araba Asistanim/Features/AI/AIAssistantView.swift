import SwiftUI

struct AIAssistantView: View {
    @StateObject private var viewModel = AIAssistantViewModel()
    @EnvironmentObject private var store: GarageStore
    @State private var draftText = ""
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            header

                            VStack(spacing: AppSpacing.xs) {
                                ForEach(viewModel.messages) { message in
                                    ChatMessageBubble(message: message)
                                        .id(message.id)
                                }

                                if viewModel.isAssistantTyping {
                                    HStack {
                                        ProgressView()
                                        Text("Düşünüyor…")
                                            .font(AppTypography.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                        Spacer()
                                    }
                                }
                            }

                            if viewModel.messages.count <= 1 {
                                suggestedQuestions
                            }

                            disclaimer
                        }
                        .padding(AppSpacing.md)
                    }
                    .onChange(of: viewModel.messages.count) {
                        guard let lastID = viewModel.messages.last?.id else { return }
                        withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }

                ChatInputPlaceholder(text: $draftText, isSendDisabled: viewModel.isAssistantTyping) {
                    viewModel.ask(draftText, insights: insights)
                    draftText = ""
                }
                .padding(AppSpacing.md)
            }
            .appScreenBackground()
            .navigationTitle("AI Araç Asistanı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    VehicleSwitcherMenu()
                }
            }
        }
    }

    private var insights: GarageInsights? {
        store.selectedVehicle.map { GarageInsights(store: store, vehicle: $0) }
    }

    /// The mascot introduces itself on the brand gradient.
    private var header: some View {
        HStack(spacing: AppSpacing.md) {
            CarMascot(glows: false)
                .frame(width: 64, height: 64)
                .padding(6)
                .background(.white.opacity(0.18), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Merhaba, ben asistanın")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                Text(store.selectedVehicle.map { "\($0.displayName) hakkında aklına takılanı sor." } ?? "Aracın hakkında aklına takılanı sor.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.lg)
        .background(BrandHeroBackground(showsCarGlyph: false))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .appShadow(AppShadow.primaryGlow)
        .padding(.bottom, AppSpacing.xs)
        .accessibilityElement(children: .combine)
    }

    private var suggestedQuestions: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Şunları sorabilirsin")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)

            ForEach(viewModel.suggestedQuestions, id: \.self) { question in
                SuggestedQuestionButton(question: question) {
                    viewModel.ask(question, insights: insights)
                }
            }
        }
    }

    private var disclaimer: some View {
        Text(PreviewData.aiDisclaimer)
            .font(AppTypography.caption)
            .foregroundStyle(AppTheme.textSecondary)
            .multilineTextAlignment(.leading)
            .padding(.top, AppSpacing.xs)
    }
}

#Preview {
    AIAssistantView()
        .environmentObject(GarageStore.preview)
}

#Preview("Dark") {
    AIAssistantView()
        .environmentObject(GarageStore.preview)
        .preferredColorScheme(.dark)
}
