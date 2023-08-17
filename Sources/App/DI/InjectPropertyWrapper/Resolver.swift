public protocol Resolver {
    func resolve<T>(_ type: T.Type, name: String?) -> T?
}
