import Foundation
import Combine

internal protocol UserDefaultsStorage: AnyObject {

    associatedtype Object: Codable

    var publisher: AnyPublisher<Object?, Never> { get }

    func get() -> Object?
    func set(_ object: Object)
    func remove()
}
