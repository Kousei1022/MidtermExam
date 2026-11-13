import Foundation
import SwiftData

@Model
final class WeightRecordModel {
    @Attribute(.unique) var id: UUID
    var user: UserModel?
    var weight: Double
    var date: Date

    init(
        id: UUID = UUID(),
        user: UserModel? = nil,
        weight: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.user = user
        self.weight = weight
        self.date = date
    }
}
