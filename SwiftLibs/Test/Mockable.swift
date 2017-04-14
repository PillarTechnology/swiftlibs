public struct Invocation {
    var name: String
    var params: [Any?]?
}

public class MockDataContainer {
    fileprivate var invocationArray = [Invocation]()
    fileprivate var definedReturnValues = [String: Any?]()
}

public protocol Mockable {
    var mockDataContainer: MockDataContainer { get set }

    func record(invocation: String, with parameters: Any?...)
    func invocationCount(for name: String) -> Int
    func parameters(for name: String, atInvocationIndex invocationIndex: Int) -> [Any?]?
    func parameter<T>(for name: String, atInvocationIndex invocationIndex: Int, atParameterIndex parameterIndex: Int) -> T?
    func setReturnValue(for name: String, with value: Any?)
    func returnValue<T>(for name: String) -> T?
    func reset()
}

public extension Mockable {
    fileprivate func allInvocation(for name: String) -> [Invocation] {
        return mockDataContainer.invocationArray.filter { (item) -> Bool in
            return item.name == name
        }
    }

    func record(invocation name: String) {
        record(invocation: name, with: nil)
    }

    func record(invocation name: String, with parameters: Any?...) {
        let newInvocation = Invocation(name: name, params: parameters)
        mockDataContainer.invocationArray.append(newInvocation)
    }

    func invocationCount(for name: String) -> Int {
        return allInvocation(for: name).count
    }

    func parameters(for name: String, atInvocationIndex invocationIndex: Int = 0) -> [Any?]? {
        if invocationIndex >= mockDataContainer.invocationArray.count || invocationIndex < 0 {
            return nil
        }

        return mockDataContainer.invocationArray[invocationIndex].params

    }

    func parameter<T>(for name: String, atInvocationIndex invocationIndex: Int = 0, atParameterIndex parameterIndex: Int = 0) -> T? {
        return parameters(for: name, atInvocationIndex: invocationIndex)?[parameterIndex] as? T
    }

    func setReturnValue(for name: String, with value: Any?) {
        mockDataContainer.definedReturnValues[name] = value
    }

    func returnValue<T>(for name: String) -> T? {
        return mockDataContainer.definedReturnValues[name] as? T
    }

    func reset() {
        mockDataContainer.definedReturnValues.removeAll(keepingCapacity: false)
        mockDataContainer.invocationArray.removeAll(keepingCapacity: false)
    }
}
