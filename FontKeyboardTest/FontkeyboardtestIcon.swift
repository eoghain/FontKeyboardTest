//
//  FontkeyboardtestIcons.swift
//

public struct FontkeyboardtestIcon {
	public static let basket = "\u{E800}"
	public static let book = "\u{E802}"
	public static let chartBar = "\u{E804}"
	public static let chartPie = "\u{E805}"
	public static let money = "\u{E801}"
	public static let videocamAlt = "\u{E806}"
	public static let write = "\u{E803}"

	public static func iconNamed(name: String) -> String {
		switch(name) {
			case "basket", "icon-basket":
				return FontkeyboardtestIcon.basket
			case "book", "icon-book":
				return FontkeyboardtestIcon.book
			case "chart-bar", "icon-chart-bar":
				return FontkeyboardtestIcon.chartBar
			case "chart-pie", "icon-chart-pie":
				return FontkeyboardtestIcon.chartPie
			case "money", "icon-money":
				return FontkeyboardtestIcon.money
			case "videocam-alt", "icon-videocam-alt":
				return FontkeyboardtestIcon.videocamAlt
			case "write", "icon-write":
				return FontkeyboardtestIcon.write
			default:
				return "\u{26A0}"
		}
	}
    
    public static let allIcons: [String] = [
        "\u{E800}",
        "\u{E802}",
        "\u{E804}",
        "\u{E805}",
        "\u{E801}",
        "\u{E806}",
        "\u{E803}"
    ]
}


public enum FontkeyboardtestIconEnum: String, CaseIterable {
    case basket = "\u{E800}"
    case book = "\u{E802}"
    case chartBar = "\u{E804}"
    case chartPie = "\u{E805}"
    case money = "\u{E801}"
    case videocamAlt = "\u{E806}"
    case write = "\u{E803}"
    case missingIcon = "\u{26A0}"
    
    var string: String {
        return self.rawValue
    }
    
    static var allCasesButMissing: [FontkeyboardtestIconEnum] {
        return allCases.filter { $0 != .missingIcon }
    }
    
    public init(rawValue: String) {
        
        switch rawValue {
            case "basket", "icon-basket", "\u{E800}": self = .basket
            case "book", "icon-book", "\u{E802}": self = .book
            case "chart-bar", "icon-chart-bar", "\u{E804}": self = .chartBar
            case "chart-pie", "icon-chart-pie", "\u{E805}": self = .chartPie
            case "money", "icon-money", "\u{E801}": self = .money
            case "videocam-alt", "icon-videocam-alt", "\u{E806}": self = .videocamAlt
            case "write", "icon-write", "\u{E803}": self = .missingIcon
        default: self = .missingIcon
        }
    }
    
//    public static func iconNamed(name: String) -> String {
//        switch(name) {
//        case "basket", "icon-basket":
//            return FontkeyboardtestIcon.basket
//        case "book", "icon-book":
//            return FontkeyboardtestIcon.book
//        case "chart-bar", "icon-chart-bar":
//            return FontkeyboardtestIcon.chartBar
//        case "chart-pie", "icon-chart-pie":
//            return FontkeyboardtestIcon.chartPie
//        case "money", "icon-money":
//            return FontkeyboardtestIcon.money
//        case "videocam-alt", "icon-videocam-alt":
//            return FontkeyboardtestIcon.videocamAlt
//        case "write", "icon-write":
//            return FontkeyboardtestIcon.write
//        default:
//            return "\u{26A0}"
//        }
//    }
    
//    public static let allIcons: [String] = [
//        "\u{E800}",
//        "\u{E802}",
//        "\u{E804}",
//        "\u{E805}",
//        "\u{E801}",
//        "\u{E806}",
//        "\u{E803}"
//    ]
}
