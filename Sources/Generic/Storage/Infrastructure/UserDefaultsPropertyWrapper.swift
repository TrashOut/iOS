import Combine
import CombineExt
import Foundation

@propertyWrapper
class UserDefaultValue<T: Codable>: StorageValue<T> {

    private lazy var userDefaults: UserDefaults = { UserDefaults.standard }()

    init(_ key: String, defaultValue: T) {
        super.init(defaultValue: defaultValue, key: key)
    }

    var wrappedValue: T {
        get {
            if let data = userDefaults.value(forKey: key) as? T {
                return data
            }

            guard let data = userDefaults.object(forKey: key) as? Data else { return defaultValue }
            let value = decode(data: data)

            return value
        }
        set(newValue) {
            let wrapper = Wrapper(value: newValue)
            userDefaults.set(encode(wrapper: wrapper), forKey: key)
            subject.send(newValue)
        }
    }

    lazy var publisher: AnyPublisher<T, Never> = {
        publisherFor(wrappedValue: wrappedValue)
    }()
}
