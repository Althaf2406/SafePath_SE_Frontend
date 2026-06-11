import Foundation
import Combine
import SwiftUI
import CoreLocation

// MARK: - CLLocationCoordinate2D Helpers

extension CLLocationCoordinate2D {
    /// Haversine distance in km to another coordinate.
    func distanceKm(to other: CLLocationCoordinate2D) -> Double {
        let R = 6371.0
        let dLat = (other.latitude - latitude) * .pi / 180
        let dLon = (other.longitude - longitude) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(latitude * .pi / 180) * cos(other.latitude * .pi / 180) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}

// MARK: - Date Formatting

extension Date {
    /// "15 Jan 2024, 10:30" style display
    var shortDisplay: String {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy, HH:mm"
        f.locale = Locale(identifier: "id_ID")
        return f.string(from: self)
    }
    
    /// Relative time: "5 minutes ago"
    var relativeDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - String Helpers

extension String {
    /// Parse ISO8601 date string
    var iso8601Date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = formatter.date(from: self) { return d }
        // Fallback without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: self)
    }
}

// MARK: - Double Helpers

extension Double {
    /// Round to given decimal places
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// Format distance: "2.5 km" or "800 m"
    var distanceDisplay: String {
        if self < 1.0 {
            return "\(Int(self * 1000)) m"
        }
        return "\(self.rounded(to: 1)) km"
    }
}

// MARK: - View Helpers

extension View {
    /// Apply SafePath card styling (SafePath design system)
    func safePathCard() -> some View {
        self
            .background(SafePathColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    /// Standard white card style used across Preparedness screens.
    func cardStyle() -> some View {
        self
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

// MARK: - TimeInterval Display

extension TimeInterval {
    /// ETA display: "5 min" or "1 hr 20 min"
    var etaDisplay: String {
        let totalMinutes = Int(self / 60)
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        }
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        return mins > 0 ? "\(hours) hr \(mins) min" : "\(hours) hr"
    }
}
