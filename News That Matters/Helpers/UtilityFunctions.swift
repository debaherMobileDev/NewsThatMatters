//
//  UtilityFunctions.swift
//  News That Matters
//
//  Created on 2026-01-04.
//

import Foundation
import UIKit

// MARK: - Date Formatting
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    func truncated(to length: Int, addEllipsis: Bool = true) -> String {
        if self.count <= length {
            return self
        }
        let endIndex = self.index(self.startIndex, offsetBy: length)
        let truncated = String(self[..<endIndex])
        return addEllipsis ? truncated + "..." : truncated
    }
    
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}

// MARK: - URL Opening
func openURL(_ urlString: String) {
    guard let url = URL(string: urlString) else { return }
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}

// MARK: - Haptic Feedback
enum HapticFeedback {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    
    func generate() {
        switch self {
        case .light, .medium, .heavy:
            let impact = UIImpactFeedbackGenerator(style: style)
            impact.impactOccurred()
        case .success, .warning, .error:
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(notificationType)
        }
    }
    
    private var style: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        default: return .medium
        }
    }
    
    private var notificationType: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        default: return .success
        }
    }
}

// MARK: - Image Caching
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}

// MARK: - Validation
struct Validator {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}

