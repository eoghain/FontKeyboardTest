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
