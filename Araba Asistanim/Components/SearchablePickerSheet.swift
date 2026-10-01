import SwiftUI

/// A generic "pick one from a searchable list" sheet — loading, error and
/// empty-search states included. Used for Marka/Model in Add Vehicle today;
/// generic enough to reuse for any future list-driven picker (e.g. Settings'
/// Units/Currency).
struct SearchablePickerSheet: View {
    let title: String
    let items: [String]
    var isLoading: Bool = false
    var errorMessage: String? = nil
    let onSelect: (String) -> Void
    var onRetry: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var filteredItems: [String] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    LoadingView(message: "Yükleniyor…")
                } else if let errorMessage {
                    FullScreenErrorView(title: "Bir şeyler ters gitti", message: errorMessage, onRetry: onRetry)
                } else if filteredItems.isEmpty {
                    EmptyStateView(
                        systemImage: "magnifyingglass",
                        title: "Sonuç yok",
                        message: query.isEmpty ? "Liste boş." : "\"\(query)\" için sonuç bulunamadı."
                    )
                } else {
                    List(filteredItems, id: \.self) { item in
                        Button {
                            onSelect(item)
                            dismiss()
                        } label: {
                            Text(item)
                                .font(AppTypography.body)
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                    .listStyle(.plain)
                    .animation(AppAnimation.fast, value: filteredItems)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Ara")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SearchablePickerSheet(
                title: "Marka Seç",
                items: ["BMW", "Toyota", "Volkswagen", "Renault", "Fiat"],
                onSelect: { _ in }
            )
        }
}
