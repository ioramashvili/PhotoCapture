import Foundation
import StoreKit

class StoreReviewHelper {
    private enum Cycle: Int {
        case _20 = 20, _80 = 80, _160 = 160
        
        static var all: [Cycle] {
            return [_20, _80, _160]
        }
        
        static func contains(value: Int) -> Bool {
            return all.map({ $0.rawValue }).contains(value)
        }
    }
    
    private static let userDefaults = UserDefaults.standard
    
    private static var targetCount: Int {
        get {
            return userDefaults.value(forKey: "targetCount") as? Int ?? 00
        }
        set {
            userDefaults.set(newValue, forKey: "targetCount")
            requestReviewIfNeeded()
            print("targetCount", newValue)
        }
    }
    
    static func increaseTargetCount(by value: Int = 1) {
        targetCount += value
    }
    
    private static func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    private static func requestReviewIfNeeded() {
        if Cycle.contains(value: targetCount) {
            requestReview()
        }
    }
}






