

import Foundation

struct Reddit : Codable {
	let kind : String?
	let child : Child?

	enum CodingKeys: String, CodingKey {

		case kind = "kind"
		case child = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		kind = try? values.decodeIfPresent(String.self, forKey: .kind)
        child = try? values.decodeIfPresent(Child.self, forKey: .child)
	}

}
