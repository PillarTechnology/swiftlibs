import UIKit
protocol iMocker {
    associatedtype MethodName_t = String
    associatedtype ParamList_t = Array<Any>
    associatedtype ReturnType_t = Any
    func setReturnValueFor(_ methodName : MethodName_t, returnValue : ReturnType_t?, n : Int)
    func getReturnValueFor(_ methodName : MethodName_t) -> ReturnType_t?
    func getParametersFor(_ methodName : MethodName_t, n : Int) -> ParamList_t?
    func getInvocationCountFor(_ methodName : MethodName_t) -> Int
    func recordInvocation(_ methodName : MethodName_t, paramList : ParamList_t?)
    func reset()
}

private extension Array {
    func get(at i: Index) -> Element? {
        var count = 0
        for item in self {
            if count == i {
                return item
            }
            count += 1
        }
        return nil
    }
}
open class Mocker : NSObject, iMocker {
    public typealias MethodName_t = String
    public typealias ParamList_t = Array<Any>
    public typealias ReturnType_t = Any

    var invocationParameterArray = Dictionary<MethodName_t, Array<ParamList_t?>>()
    var definedReturnValues = Dictionary<MethodName_t, Array<ReturnType_t?>>()
    var definedReturnValueRequestCount = Dictionary<MethodName_t, Int>()
    // If unspecified (or negative), n will append the returnValue to the queue of returnValues
    // If specified, n will override the already-specified returnValue
    open func setReturnValueFor(_ methodName : MethodName_t, returnValue : ReturnType_t?, n : Int = -1) {
        if (definedReturnValues[methodName] == nil) {
            definedReturnValues[methodName] = Array<ReturnType_t?>()
            definedReturnValueRequestCount[methodName] = 0
        }
        if (n < 0) {
            definedReturnValues[methodName]!.append(returnValue)
        }
        else {
            definedReturnValues[methodName]![n] = returnValue
        }
    }
    open func getReturnValueFor(_ methodName : MethodName_t) -> ReturnType_t? {
        guard let requestCount = definedReturnValueRequestCount[methodName],
            let returnValues = definedReturnValues[methodName] else {
            return nil
        }
        definedReturnValueRequestCount[methodName] = requestCount + 1
        assert(returnValues.count > 0, "Could not return \(requestCount)th value for \(methodName); no return values were set.")
        if requestCount < returnValues.count {
            return returnValues[requestCount]
        }
        else {
            return returnValues[returnValues.count - 1]
        }
    }
    open func getParametersFor(_ methodName : MethodName_t, n : Int = 0) -> ParamList_t? {
        guard let methodName = invocationParameterArray[methodName] else { return nil }
        let parametersForAllInvocations : Array<ParamList_t?> = methodName
        return parametersForAllInvocations.get(at: n) ?? nil
    }
    open func getInvocationCountFor(_ methodName : MethodName_t) -> Int {
        let parametersForAllInvocations : Array<ParamList_t?>? = invocationParameterArray[methodName]
        return ( (parametersForAllInvocations == nil) ? 0 : parametersForAllInvocations!.count )
    }
    open func recordInvocation(_ methodName : MethodName_t, paramList : ParamList_t? = []) {
        if (invocationParameterArray[methodName] == nil) {
            invocationParameterArray[methodName] = Array<ParamList_t?>()
        }
        invocationParameterArray[methodName]!.append(paramList)
    }
    open func reset() {
        invocationParameterArray.removeAll(keepingCapacity: false)
        definedReturnValues.removeAll(keepingCapacity: false)
        definedReturnValueRequestCount.removeAll(keepingCapacity: false)
    }
}
