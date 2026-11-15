import SwiftUI

// MARK: - Main Todo Overview View
struct TodoOverviewView: View {
    @ObservedObject var dashboardVM: TodoDashboardViewModel
    @ObservedObject var authCoordinator: AuthCoordinator

    @State private var showCreateModal: Bool = false
    @State private var activeEditRecord: TodoRecord?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Metric Counters
                HStack(spacing: 12) {
                    metricCard(
                        title: "Pending",
                        count: dashboardVM.pendingCount,
                        color: Color(red: 0.98, green: 0.45, blue: 0.25),
                        icon: "clock.badge.exclamationmark"
                    )

                    metricCard(
                        title: "Completed",
                        count: dashboardVM.completedCount,
                        color: Color(red: 0.20, green: 0.70, blue: 0.45),
                        icon: "checkmark.circle.fill"
                    )
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 12)

                // Filter Segment
                Picker("Filter", selection: $dashboardVM.currentFilter) {
                    ForEach(DisplayFilter.allCases) { filterOption in
                        Text(filterOption.rawValue).tag(filterOption)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 10)

                Divider()

                // List Section
                if dashboardVM.filteredRecords.isEmpty {
                    emptyNoticeView
                } else {
                    List {
                        ForEach(dashboardVM.filteredRecords) { record in
                            TodoRowItem(
                                record: record,
                                onToggleStatus: {
                                    Task {
                                        await dashboardVM.toggleDone(for: record)
                                    }
                                },
                                onSelect: {
                                    activeEditRecord = record
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        await dashboardVM.remove(record: record)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        dashboardVM.bindRealtimeListener()
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("TaskFocus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section("Active User") {
                            Text(authCoordinator.loggedInEmail)
                        }
                        Button(role: .destructive) {
                            authCoordinator.logOut()
                        } label: {
                            Label("Sign Out", systemImage: "power")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.98, green: 0.45, blue: 0.25))
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateModal = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.98, green: 0.45, blue: 0.25))
                    }
                }
            }
            .sheet(isPresented: $showCreateModal) {
                TaskFormSheet { title, desc, priority in
                    Task {
                        await dashboardVM.createTodo(title: title, description: desc, priority: priority)
                    }
                }
            }
            .sheet(item: $activeEditRecord) { record in
                TaskFormSheet(existingRecord: record) { updatedTitle, updatedDesc, updatedPriority in
                    var updated = record
                    updated.title = updatedTitle
                    updated.descriptionText = updatedDesc
                    updated.priority = updatedPriority
                    Task {
                        await dashboardVM.saveEdit(record: updated)
                    }
                }
            }
        }
    }

    private func metricCard(title: String, count: Int, color: Color, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 3, y: 1)
    }

    private var emptyNoticeView: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.6))
            Text("No Tasks Here")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            Text("Add tasks using the plus button above to get started.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}
