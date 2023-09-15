

import Foundation

// MARK: - CategoriesModel
struct CategoriesModel: Codable {
    let code: Int
    let body: Body
}

// MARK: - Body
struct Body: Codable {
    let categories: [Category]
    let agetypes: [Agetype]
}

// MARK: - Agetype
struct Agetype: Codable {
    let agetypeID, title: String

    enum CodingKeys: String, CodingKey {
        case agetypeID = "agetype_id"
        case title
    }
}

// MARK: - Category
struct Category: Codable {
    let categoryID, title: String

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case title
    }
}
