import Foundation
import Nimble

/// Invocation Count
public func invoke<T: Mockable>(_ name: String, times: Int = 1) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in

        failureMessage.postfixMessage = "invoke \(name) \(times) times"

        if let mockable = try? actualExpression.evaluate() {
            failureMessage.actualValue = "\(mockable?.invocationCount(for: name) ?? 0) invocations"
            return mockable?.invocationCount(for: name) == times
        }

        return false
    }
}

/// Equatable
public func invoke<T: Mockable, E: Equatable>(_ name: String, atInvocation invocationIndex: Int = 0, withParameter parameter: E?, at parameterIndex: Int = 0) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in

        failureMessage.postfixMessage = "invoke \(name) with \(parameter) at index \(parameterIndex) on invocation \(invocationIndex)"

        if let mockable = try actualExpression.evaluate() {
            let actualParameter: E? = mockable.parameter(for: name, at: parameterIndex, andInvocation: invocationIndex)
            failureMessage.actualValue = "\(actualParameter)"
            return actualParameter == parameter
        }

        return false
    }
}

/// Identity
public func invoke<T: Mockable, E: AnyObject>(_ name: String, atInvocation invocationIndex: Int = 0, withIdenticalParameter parameter: E?, at parameterIndex: Int = 0) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in

        failureMessage.postfixMessage = "invoke \(name) with \(parameter) at index \(parameterIndex) on invocation \(invocationIndex)"

        if let mockable = try actualExpression.evaluate() {
            let actualParameter: E? = mockable.parameter(for: name, at: parameterIndex, andInvocation: invocationIndex)
            failureMessage.actualValue = "\(actualParameter)"
            return actualParameter === parameter
        }

        return false
    }
}

/// Closure Matcher
public func invoke<T: Mockable, U>(_ name: String, atInvocation invocationIndex: Int = 0, atParameterIndex parameterIndex: Int = 0, withMatcher matcher: @escaping ((U?) -> Bool?)) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in

        failureMessage.postfixMessage = "invoke \(name) with matching parameter at index \(parameterIndex) on invocation \(invocationIndex)"

        if let mockable = try actualExpression.evaluate() {
            let actualValue: U? = mockable.parameter(for: name, at: parameterIndex, andInvocation: invocationIndex)
            failureMessage.actualValue = "parameter as \(actualValue)"
            return matcher( actualValue ) ?? false
        }

        return false
    }
}
