
import Foundation
struct Child : Codable {
    let title : String?
    let numComments : Int?
    let score : Int?
    let thumbnail : String?
    let thumbnailHeight : Double?
    let thumbnailWidth : Double?
    let created: Int64?

	enum CodingKeys: String, CodingKey {

        case created = "created"
        case title = "title"
        case numComments = "num_comments"
        case thumbnailHeight = "thumbnail_height"
        case thumbnailWidth = "thumbnail_width"
        case score = "score"
        case thumbnail = "thumbnail"
        
	}

	init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        created = try? values.decodeIfPresent(Int64.self, forKey: .created)
        title = try? values.decodeIfPresent(String.self, forKey: .title)
        numComments = try? values.decodeIfPresent(Int.self, forKey: .numComments)
        score = try? values.decodeIfPresent(Int.self, forKey: .score)
        thumbnail = try? values.decodeIfPresent(String.self, forKey: .thumbnail)
        thumbnailWidth = try? values.decodeIfPresent(Double.self, forKey: .thumbnailWidth)
        thumbnailHeight = try? values.decodeIfPresent(Double.self, forKey: .thumbnailHeight)

    }

}
