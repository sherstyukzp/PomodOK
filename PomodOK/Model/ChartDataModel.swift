import Foundation

struct ChartDataModel {
    var label: String
    var value: Int
}

enum ChartMetric: String, CaseIterable {
    case sessions = "Sessions"
    case minutes = "Minutes"
}
