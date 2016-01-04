
import Foundation
@testable import SwiftLibs

class MockWebRequestSessionDelegate : WebRequest._SessionDelegate {
    private static var _originalStaticConstructor : (() -> WebRequest._SessionDelegate)?
    private static var _mockedSessionDelegate : MockWebRequestSessionDelegate!

    let mocker : Mocker = Mocker()

    static func mockConstructor() -> MockWebRequestSessionDelegate {
        if (MockWebRequestSessionDelegate._originalStaticConstructor != nil) {
            MockWebRequestSessionDelegate._originalStaticConstructor = WebRequest._SessionDelegate.newInstance
        }

        _mockedSessionDelegate = MockWebRequestSessionDelegate()

        WebRequest._SessionDelegate.newInstance = {
            () -> WebRequest._SessionDelegate in
                return _mockedSessionDelegate
        }

        return _mockedSessionDelegate
    }

    static func restoreConstructor() {
        if (MockWebRequestSessionDelegate._originalStaticConstructor != nil) {
            WebRequest._SessionDelegate.newInstance = MockWebRequestSessionDelegate._originalStaticConstructor
        }
    }

    override func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        mocker.recordInvocation("URLSession", paramList: [session, task, response, request, completionHandler ])
    }

    override init() {
        super.init()
    }
}
