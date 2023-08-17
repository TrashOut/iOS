import Combine
import Foundation

internal class StorageValue<T: Codable> {

    struct Wrapper: Codable {
        let value: T
    }

    private let listDecoder = PropertyListDecoder()
    private let listEncoder = PropertyListEncoder()

    internal let defaultValue: T
    internal let key: String

    init(defaultValue: T, key: String) {
        self.defaultValue = defaultValue
        self.key = key
    }

    let subject: PassthroughSubject<T, Never> = .init()

    func decode(data: Data) -> T {
        (try? listDecoder.decode(Wrapper.self, from: data))?.value ?? defaultValue
    }

    func encode(wrapper: Wrapper) -> Data? {
        try? listEncoder.encode(wrapper)
    }

    func publisherFor(wrappedValue: T) -> AnyPublisher<T, Never> {
        subject.prepend(wrappedValue)
            .share(replay: 1)
            .eraseToAnyPublisher()
    }
}
