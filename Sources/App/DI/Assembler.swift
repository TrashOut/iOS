import Swinject

extension Assembler {
    public static let shared: Assembler = {
        let container = Container()
        let assembler = Assembler(appAssemblyList, container: container)
        InjectSettings.resolver = container

        return assembler
    }()
}

extension Container: Resolver {}
