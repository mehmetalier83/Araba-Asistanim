import SwiftUI

/// One vehicle's full expense ledger: a premium summary row, then every
/// expense grouped by day (newest first), with swipe-to-edit / swipe-to-
/// delete. Reads the unified ledger (expenses + fuel + completed
/// maintenance) from GarageStore, so it's always in sync with every tab.
struct ExpensesListView: View {
    let vehicle: Vehicle

    @EnvironmentObject private var store: GarageStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isShowingAddExpense = false
    @State private var editingExpense: ExpenseRecord?

    private var insights: GarageInsights { GarageInsights(store: store, vehicle: vehicle) }
    private var expenses: [ExpenseRecord] { store.spending(for: vehicle.id) }
    private var thisMonthExpenses: [ExpenseRecord] {
        expenses.filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) }
    }

    private var groupedExpenses: [(header: String, records: [ExpenseRecord])] {
        let sorted = expenses.sorted { $0.date > $1.date }
        let groups = Dictionary(grouping: sorted) { Calendar.current.startOfDay(for: $0.date) }
        return groups.keys.sorted(by: >).map { day in
            (header: day.formattedListSectionHeader(), records: groups[day] ?? [])
        }
    }

    var body: some View {
        Group {
            if expenses.isEmpty {
                EmptyStateView(
                    systemImage: "creditcard.fill",
                    title: "Henüz gider yok",
                    message: "Yakıt, bakım, sigorta ve diğer araç giderlerini tek bir yerde takip et.",
                    actionTitle: "İlk Giderini Ekle"
                ) {
                    isShowingAddExpense = true
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section {
                        summaryRow
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: AppSpacing.md, bottom: AppSpacing.md, trailing: AppSpacing.md))
                    }

                    ForEach(groupedExpenses, id: \.header) { group in
                        Section {
                            ForEach(group.records) { expense in
                                // Link laid under the card so the List adds no chevron of its own.
                                ExpenseRowView(expense: expense)
                                    .background {
                                        NavigationLink {
                                            ExpenseDetailView(vehicle: vehicle, expenseID: expense.id)
                                        } label: {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 0, leading: AppSpacing.md, bottom: AppSpacing.xs, trailing: AppSpacing.md))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                                            store.deleteSpending(expense)
                                        }
                                        HapticFeedback.success()
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }

                                    Button {
                                        editingExpense = expense
                                    } label: {
                                        Label("Düzenle", systemImage: "pencil")
                                    }
                                    .tint(AppTheme.primary)
                                }
                            }
                        } header: {
                            Text(group.header)
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                                .textCase(nil)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .appScreenBackground()
        .navigationTitle("Giderler")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Gider Ekle")
            }
        }
        .sheet(isPresented: $isShowingAddExpense) {
            AddExpenseView(vehicle: vehicle) { expense in
                withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                    store.addExpense(expense)
                }
            }
        }
        .sheet(item: $editingExpense) { expense in
            LedgerEditSheet(vehicle: vehicle, expense: expense)
        }
    }

    /// This month's total on the brand gradient, with the year and all-time
    /// totals as chips.
    private var summaryRow: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Bu Ay · \(thisMonthExpenses.count) işlem")
                    .font(AppTypography.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                Text(insights.thisMonthTotal.formattedCurrencyTL())
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }

            HStack(spacing: AppSpacing.xs) {
                summaryChip(title: "Bu yıl", value: insights.thisYearTotal.formattedCurrencyTL())
                summaryChip(title: "Toplam", value: insights.allTimeTotal.formattedCurrencyTL())
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandHeroBackground(showsCarGlyph: false))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .appShadow(AppShadow.primaryGlow)
        .accessibilityElement(children: .combine)
    }

    private func summaryChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.75))
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 6)
        .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// A single row in the expenses list: category icon + name + service on the
/// leading side, amount + mileage on the trailing side.
private struct ExpenseRowView: View {
    let expense: ExpenseRecord

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.sm) {
            Image(systemName: expense.category.systemImage)
                .font(.system(size: AppSizes.iconSmall, weight: .semibold))
                .foregroundStyle(expense.category.tintColor)
                .frame(width: 42, height: 42)
                .background(expense.category.tintColor.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category.displayName)
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppTheme.textPrimary)

                if let serviceName = expense.serviceName, !serviceName.isEmpty {
                    Text(serviceName)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(expense.amount.formattedCurrencyTL())
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                if let mileage = expense.mileageKm {
                    Text(mileage.formattedMileage())
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(AppSpacing.md)
        .appCard(cornerRadius: 18)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(
            "\(expense.category.displayName), \(expense.serviceName ?? ""), \(expense.amount.formattedCurrencyTL())"
        )
    }
}

#Preview {
    NavigationStack {
        ExpensesListView(vehicle: PreviewData.vehicles[0])
    }
    .environmentObject(GarageStore.preview)
}

#Preview("Dark") {
    NavigationStack {
        ExpensesListView(vehicle: PreviewData.vehicles[0])
    }
    .environmentObject(GarageStore.preview)
    .preferredColorScheme(.dark)
}

#Preview("Empty") {
    NavigationStack {
        ExpensesListView(vehicle: PreviewData.vehicles[0])
    }
    .environmentObject(GarageStore(userID: "empty", repository: InMemoryGarageRepository()))
}
