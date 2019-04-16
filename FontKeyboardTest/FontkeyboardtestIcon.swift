//
//  FontkeyboardtestIcon.swift
//

public enum FontkeyboardtestIcon: String, CaseIterable {
	case basket = "\u{E800}"
	case bell = "\u{E80E}"
	case book = "\u{E802}"
	case bullhorn = "\u{E80D}"
	case chartBar = "\u{E804}"
	case chartPie = "\u{E805}"
	case download = "\u{E80B}"
	case info = "\u{E80F}"
	case mail = "\u{E808}"
	case mobile = "\u{E80C}"
	case money = "\u{E801}"
	case search = "\u{E807}"
	case thumbsDown = "\u{E80A}"
	case thumbsUp = "\u{E809}"
	case videocamAlt = "\u{E806}"
	case write = "\u{E803}"
	case missingIcon = "\u{26A0}"

	var string: String { return rawValue }

	var name: String {
		switch(self) {
			case .basket: return "basket"
			case .bell: return "bell"
			case .book: return "book"
			case .bullhorn: return "bullhorn"
			case .chartBar: return "chart-bar"
			case .chartPie: return "chart-pie"
			case .download: return "download"
			case .info: return "info"
			case .mail: return "mail"
			case .mobile: return "mobile"
			case .money: return "money"
			case .search: return "search"
			case .thumbsDown: return "thumbs-down"
			case .thumbsUp: return "thumbs-up"
			case .videocamAlt: return "videocam-alt"
			case .write: return "write"
			default: return "missing-icon"
		}
	}

	var prefixedName: String {
		switch(self) {
			case .basket: return "icon-basket"
			case .bell: return "icon-bell"
			case .book: return "icon-book"
			case .bullhorn: return "icon-bullhorn"
			case .chartBar: return "icon-chart-bar"
			case .chartPie: return "icon-chart-pie"
			case .download: return "icon-download"
			case .info: return "icon-info"
			case .mail: return "icon-mail"
			case .mobile: return "icon-mobile"
			case .money: return "icon-money"
			case .search: return "icon-search"
			case .thumbsDown: return "icon-thumbs-down"
			case .thumbsUp: return "icon-thumbs-up"
			case .videocamAlt: return "icon-videocam-alt"
			case .write: return "icon-write"
			default: return "icon-missing"
		}
	}

	static var allCasesButMissing: [FontkeyboardtestIcon] {
		return allCases.filter { $0 != .missingIcon }
	}

	public init(rawValue: String) {
		switch rawValue {
			case "basket", "icon-basket", "\u{E800}": self = .basket
			case "bell", "icon-bell", "\u{E80E}": self = .bell
			case "book", "icon-book", "\u{E802}": self = .book
			case "bullhorn", "icon-bullhorn", "\u{E80D}": self = .bullhorn
			case "chart-bar", "icon-chart-bar", "\u{E804}": self = .chartBar
			case "chart-pie", "icon-chart-pie", "\u{E805}": self = .chartPie
			case "download", "icon-download", "\u{E80B}": self = .download
			case "info", "icon-info", "\u{E80F}": self = .info
			case "mail", "icon-mail", "\u{E808}": self = .mail
			case "mobile", "icon-mobile", "\u{E80C}": self = .mobile
			case "money", "icon-money", "\u{E801}": self = .money
			case "search", "icon-search", "\u{E807}": self = .search
			case "thumbs-down", "icon-thumbs-down", "\u{E80A}": self = .thumbsDown
			case "thumbs-up", "icon-thumbs-up", "\u{E809}": self = .thumbsUp
			case "videocam-alt", "icon-videocam-alt", "\u{E806}": self = .videocamAlt
			case "write", "icon-write", "\u{E803}": self = .write
			default: self = .missingIcon
		}
	}
}