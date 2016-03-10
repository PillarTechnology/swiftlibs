
import Foundation
import UIKit

public protocol iMocker {
    typealias MethodName_t = String
    typealias ParamList_t = Array<Any>
    typealias ReturnType_t = Any
    func setReturnValueFor(methodName : MethodName_t, returnValue : ReturnType_t?, n : Int)
    func getReturnValueFor(methodName : MethodName_t) -> ReturnType_t?
    func getParametersFor(methodName : MethodName_t, n : Int) -> ParamList_t?
    func getInvocationCountFor(methodName : MethodName_t) -> Int
    func recordInvocation(methodName : MethodName_t, paramList : ParamList_t?)
    func reset()
}

public class Mocker : NSObject, iMocker {
    public typealias MethodName_t = String
    public typealias ParamList_t = Array<Any>
    public typealias ReturnType_t = Any

    private var _invocationParameterArray = Dictionary<MethodName_t, Array<ParamList_t?>>()
    private var _definedReturnValues = Dictionary<MethodName_t, Array<ReturnType_t?>>()
    private var _definedReturnValueRequestCount = Dictionary<MethodName_t, Int>()

    // NOTE:
    //  If unspecified (or negative), n will append the returnValue to the queue of returnValues
    //  If specified, n will override the already-specified returnValue
    public func setReturnValueFor(methodName : MethodName_t, returnValue : ReturnType_t?, n : Int = -1) {
        if (_definedReturnValues[methodName] == nil) {
            _definedReturnValues[methodName] = Array<ReturnType_t?>()
            _definedReturnValueRequestCount[methodName] = 0
        }
        if (n < 0) {
            _definedReturnValues[methodName]!.append(returnValue)
        }
        else {
            _definedReturnValues[methodName]![n] = returnValue
        }
    }

    public func getReturnValueFor(methodName : MethodName_t) -> ReturnType_t? {
        let requestCount : Int = _definedReturnValueRequestCount[methodName]!
        let availableReturnValueCount : Int = _definedReturnValues[methodName]!.count
        assert(requestCount < availableReturnValueCount, "Could not return \(requestCount)th value for \(methodName). Only \(availableReturnValueCount) values set.")
        _definedReturnValueRequestCount[methodName]! += 1
        return _definedReturnValues[methodName]![requestCount]
    }

    public func getParametersFor(methodName : MethodName_t, n : Int = 0) -> ParamList_t? {
        let parametersForAllInvocations : Array<ParamList_t?>? = _invocationParameterArray[methodName]

        if (n < parametersForAllInvocations?.count) {
            return parametersForAllInvocations?[n]
        }
        return nil
    }

    public func getInvocationCountFor(methodName : MethodName_t) -> Int {
        let parametersForAllInvocations : Array<ParamList_t?>? = _invocationParameterArray[methodName]
        return ( (parametersForAllInvocations == nil) ? 0 : parametersForAllInvocations!.count )
    }

    public func recordInvocation(methodName : MethodName_t, paramList : ParamList_t?) {
        if (_invocationParameterArray[methodName] == nil) {
            _invocationParameterArray[methodName] = Array<ParamList_t?>()
        }
        _invocationParameterArray[methodName]!.append(paramList)
    }

    public func reset() {
        _invocationParameterArray.removeAll(keepCapacity: false)
        _definedReturnValues.removeAll(keepCapacity: false)
        _definedReturnValueRequestCount.removeAll(keepCapacity: false)
    }
}
