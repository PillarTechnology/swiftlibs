import Foundation

public protocol Mockable {
    var mocker: Mocker { get set }

    func record(invocation: String, with parameters: Any?...)
    func invocationCount(for name: String) -> Int
    func parameters(for name: String, at index: Int) -> [Any]
    func parameter<T>(for name: String, at index: Int, andInvocation invocation: Int) -> T?
    func setReturnValue(for name: String, with value: Any?, index: Int)
    func returnValue<T>(for name: String) -> T?
    func reset()
}

public extension Mockable {
    // Set to "Any?" to avoid Swift 3 compiler warnings about implicit casting.
    // There is a bug where the warning will not display in a source file at
    // https://bugs.swift.org/browse/SR-2921
    func record(invocation name: String, with parameters: Any?...) {
        mocker.recordInvocation(name, paramList: parameters as [Any?])
    }

    func invocationCount(for name: String) -> Int {
        return mocker.getInvocationCountFor(name)
    }

    func parameters(for name: String, at index: Int = 0) -> [Any] {
        return mocker.getParametersFor(name, n: index) ?? []
    }

    func parameter<T>(for name: String, at index: Int, andInvocation invocation: Int = 0) -> T? {
        return parameters(for: name, at: invocation).value(at: index) as? T
    }

    func setReturnValue(for name: String, with value: Any?, index: Int = -1) {
        mocker.setReturnValueFor(name, returnValue: value, n: index)
    }

    func returnValue<T>(for name: String) -> T? {
        return mocker.getReturnValueFor(name) as? T
    }

    func reset() {
        mocker.reset()
    }
}

private extension Array {
    func value(at index: Int) -> Element? {
        guard index >= 0 && index < endIndex else {
            return nil
        }
        return self[index]
    }
}
