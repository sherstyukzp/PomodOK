import Foundation
import SwiftUI

struct ChartDataModel {
    var label: String
    var value: Int
}

enum ChartMetric: String, CaseIterable {
    case sessions = "Sessions"
    case minutes = "Minutes"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}
