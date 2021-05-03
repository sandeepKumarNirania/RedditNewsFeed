
import Foundation
struct RootData : Codable {
	let modhash : String?
	let dist : Int?
	let children : [Reddit]?
	let after : String?
	let before : String?

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        modhash = UUID().uuidString
		dist = try? values.decodeIfPresent(Int.self, forKey: .dist)
		children = try? values.decodeIfPresent([Reddit].self, forKey: .children)
		after = try? values.decodeIfPresent(String.self, forKey: .after)
		before = try? values.decodeIfPresent(String.self, forKey: .before)
	}

}
