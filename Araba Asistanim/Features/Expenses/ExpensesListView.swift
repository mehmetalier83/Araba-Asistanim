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

    private let summaryColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

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
                                NavigationLink {
                                    ExpenseDetailView(vehicle: vehicle, expenseID: expense.id)
                                } label: {
                                    ExpenseRowView(expense: expense)
                                }
                                .listRowInsets(EdgeInsets(top: 0, leading: AppSpacing.md, bottom: 0, trailing: AppSpacing.md))
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
                                .font(AppTypography.captionEmphasized)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(AppTheme.groupedBackground)
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

    private var summaryRow: some View {
        LazyVGrid(columns: summaryColumns, spacing: AppSpacing.sm) {
            StatisticCard(statistic: Statistic(
                title: "Bu Ay · \(thisMonthExpenses.count) işlem",
                value: insights.thisMonthTotal.formattedCurrencyTL(),
                systemImage: "calendar"
            ))

            StatisticCard(statistic: Statistic(
                title: "Bu Yıl",
                value: insights.thisYearTotal.formattedCurrencyTL(),
                systemImage: "chart.bar.fill"
            ))

            StatisticCard(statistic: Statistic(
                title: "Toplam",
                value: insights.allTimeTotal.formattedCurrencyTL(),
                systemImage: "banknote.fill"
            ))
        }
    }
}

/// A single row in the expenses list: category icon + name + service on the
/// leading side, amount + mileage on the trailing side.
private struct ExpenseRowView: View {
    let expense: ExpenseRecord

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: expense.category.systemImage)
                .font(.system(size: AppSizes.iconSmall))
                .foregroundStyle(expense.category.tintColor)
                .frame(width: AppSizes.iconLarge, height: AppSizes.iconLarge)
                .background(expense.category.tintColor.opacity(0.12))
                .clipShape(Circle())
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
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppTheme.textPrimary)

                if let mileage = expense.mileageKm {
                    Text(mileage.formattedMileage())
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(.vertical, AppSpacing.sm)
        .accessibilityElement(children: .combine)
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
