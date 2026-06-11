import Foundation
import Combine

/// Person 2: Manages notification list and read state.
@MainActor
final class NotificationViewModel: ObservableObject {

    // MARK: - Published State

    @Published var notifications: [FamilyNotification] = []
    @Published var unreadCount: Int = 0
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        // Recalculate unreadCount whenever notifications array changes.
        $notifications
            .map { $0.filter { !$0.isRead }.count }
            .assign(to: &$unreadCount)
    }

    // MARK: - Actions

    /// Appends a new incoming notification to the list.
    func receive(_ notification: FamilyNotification) {
        notifications.insert(notification, at: 0)
    }

    /// Marks a single notification as read by ID.
    func markAsRead(id: String) {
        guard let idx = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[idx].isRead = true
    }

    /// Marks all notifications as read.
    func markAllAsRead() {
        for idx in notifications.indices {
            notifications[idx].isRead = true
        }
    }

    /// Removes a single notification by ID.
    func remove(id: String) {
        notifications.removeAll { $0.id == id }
    }

    /// Clears all notifications.
    func clearAll() {
        notifications.removeAll()
    }

    /// Returns only notifications of a specific type.
    func notifications(ofType type: FamilyNotification.NotificationType) -> [FamilyNotification] {
        notifications.filter { $0.type == type }
    }

    // MARK: - Helpers

    /// Clears any displayed error message.
    func clearError() {
        errorMessage = nil
    }
    
    /// Simulates receiving a disaster preparation guide notification.
    func simulatePrepGuideNotification(for disasterType: String) {
        let notification = FamilyNotification(
            title: "\(disasterType) Warning",
            body: "A \(disasterType) alert has been issued in your area. Tap here to view the preparation guide and checklist.",
            type: .prepGuide,
            priority: .high,
            deepLinkAction: .openPrepGuide
        )
        receive(notification)
    }
}
