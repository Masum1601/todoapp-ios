import SwiftUI

// MARK: - Task Creator / Editor Modal Sheet
struct TaskFormSheet: View {
    @Environment(\.dismiss) private var dismiss

    var existingRecord: TodoRecord?
    var onConfirm: (String, String, PriorityLevel) -> Void

    @State private var taskTitle: String = ""
    @State private var taskDesc: String = ""
    @State private var selectedPriority: PriorityLevel = .normal
    @State private var showEmptyTitleAlert: Bool = false

    var isEditing: Bool {
        existingRecord != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Information") {
                    TextField("Title", text: $taskTitle)
                        .font(.system(size: 16))

                    TextField("Description (optional)", text: $taskDesc, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.system(size: 14))
                }

                Section("Priority Level") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(PriorityLevel.allCases, id: \.self) { level in
                            HStack {
                                Circle()
                                    .fill(level.accentColor)
                                    .frame(width: 8, height: 8)
                                Text(level.displayText)
                            }
                            .tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") {
                        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedTitle.isEmpty {
                            showEmptyTitleAlert = true
                        } else {
                            onConfirm(trimmedTitle, taskDesc.trimmingCharacters(in: .whitespacesAndNewlines), selectedPriority)
                            dismiss()
                        }
                    }
                    .fontWeight(.bold)
                    .tint(Color(red: 0.98, green: 0.45, blue: 0.25))
                }
            }
            .alert("Missing Information", isPresented: $showEmptyTitleAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Task title cannot be empty.")
            }
            .onAppear {
                if let record = existingRecord {
                    taskTitle = record.title
                    taskDesc = record.descriptionText
                    selectedPriority = record.priority
                }
            }
        }
    }
}
