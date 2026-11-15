import SwiftUI

// MARK: - Individual Todo Row View
struct TodoRowItem: View {
    let record: TodoRecord
    let onToggleStatus: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Left priority color accent strip
            RoundedRectangle(cornerRadius: 3)
                .fill(record.priority.accentColor)
                .frame(width: 4, height: 48)

            // Custom Checkbox
            Button(action: onToggleStatus) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(record.isDone ? Color.clear : Color.secondary.opacity(0.4), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(record.isDone ? Color(red: 0.98, green: 0.45, blue: 0.25) : Color.clear)
                        )
                        .frame(width: 24, height: 24)

                    if record.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Main Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(record.isDone ? .secondary : .primary)
                    .strikethrough(record.isDone, color: .secondary)
                    .lineLimit(1)

                if !record.descriptionText.isEmpty {
                    Text(record.descriptionText)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    // Priority Pill
                    HStack(spacing: 3) {
                        Image(systemName: record.priority.symbol)
                            .font(.system(size: 10))
                        Text(record.priority.displayText)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(record.priority.accentColor.opacity(0.15))
                    .foregroundColor(record.priority.accentColor)
                    .cornerRadius(6)

                    Text(formatTimestamp(record.dateCreated))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
