import Foundation
import Combine

// MARK: - SafePath Constants

enum AppConstants {
    
    /// Backend API base URL (change for production deployment)
    static let apiBaseURL = "http://127.0.0.1:3000/api"
    
    /// Default search radius in km for nearby queries
    static let defaultRadiusKm: Double = 10.0
    
    /// Alert proximity threshold in km — triggers local notification
    static let alertProximityThresholdKm: Double = 100.0
    
    /// Map default region span in degrees
    static let defaultMapSpanDelta: Double = 0.05
    
    /// Cache TTL for shelter data (seconds)
    static let shelterCacheTTL: TimeInterval = 300
}

// MARK: - Design Tokens

import SwiftUI

enum SafePathColors {
    // Primary — deep navy matching screenshots
    static let primaryBlue    = Color(red: 0.04, green: 0.11, blue: 0.38)   // #0B1C61
    static let accentBlue     = Color(red: 0.05, green: 0.13, blue: 0.42)   // #0D2167
    
    // Semantic
    static let dangerRed      = Color(red: 0.80, green: 0.14, blue: 0.14)   // #CC2424
    static let safeGreen      = Color(red: 0.13, green: 0.72, blue: 0.35)   // #22B85A
    static let warningOrange  = Color(red: 0.95, green: 0.60, blue: 0.07)   // #F29912
    static let offlineGray    = Color(red: 0.55, green: 0.55, blue: 0.60)   // #8C8C99
    
    // Backgrounds matching screenshot pale blue tint
    static let backgroundLight = Color(red: 0.93, green: 0.95, blue: 1.0)   // #EDF2FF
    static let cardBackground  = Color.white
    static let lightBlueCard   = Color(red: 0.90, green: 0.93, blue: 1.0)   // #E6EDFF
    static let lightRedCard    = Color(red: 1.0,  green: 0.93, blue: 0.93)  // #FFEDED
    
    // Text
    static let textPrimary     = Color(red: 0.06, green: 0.08, blue: 0.20)  // #101433
    static let textSecondary   = Color(red: 0.42, green: 0.45, blue: 0.52)  // #6B7385
}

enum SafePathFonts {
    static let largeTitle  = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title       = Font.system(size: 22, weight: .bold, design: .rounded)
    static let headline    = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body        = Font.system(size: 15, weight: .regular, design: .default)
    static let caption     = Font.system(size: 13, weight: .regular, design: .default)
    static let buttonLabel = Font.system(size: 16, weight: .semibold, design: .rounded)
}
