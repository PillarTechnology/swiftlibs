import Foundation

public class MockWebRequest : WebRequest {
    var mocker : Mocker = Mocker()

    private static var _originalRandomFunction : (() -> Int)?
    public static func mockRandomFunction(var randomFunction : (() -> Int)?) {
        if (randomFunction == nil) {
            var i : Int = 0
            randomFunction = {
                () -> Int in
                    return i++
            }
        }

        if (MockWebRequest._originalRandomFunction == nil) {
            MockWebRequest._originalRandomFunction = WebRequest._generateRandomNumber
        }

        WebRequest._generateRandomNumber = randomFunction
    }
    public static func restoreRandomFunction() {
        if (MockWebRequest._originalRandomFunction != nil) {
            WebRequest._generateRandomNumber = MockWebRequest._originalRandomFunction
        }
    }

    public override func setUrl(url: String) {
        self.mocker.recordInvocation("setUrl", paramList: [url])
    }

    public override func setMethod(method: HttpMethod) {
        self.mocker.recordInvocation("setMethod", paramList: [method])
    }

    public override func setHeader(header header: String, value: String) {
        self.mocker.recordInvocation("setHeader", paramList: [header, value])
    }

    public override func setGetParam(key key: String, value: String) {
        self.mocker.recordInvocation("setGetParam", paramList: [key, value])
    }

    public override func setPostParam(key key: String, value: String) {
        self.mocker.recordInvocation("setPostParam", paramList: [key, value])
    }

    public override func setFollowRedirects(followRedirects: Bool) {
        self.mocker.recordInvocation("setFollowRedirects", paramList: [followRedirects])
    }

    public override func addCookie(key key: String, value: String?) {
        if (value != nil) {
            self.mocker.recordInvocation("addCookie", paramList: [key, value!])
        }
        else {
            self.mocker.recordInvocation("addCookie", paramList: [key, value])
        }
    }

    public override func addCookie(keyValuePair: String) {
        self.mocker.recordInvocation("addCookie", paramList: [keyValuePair])
    }

    public override func addMultiPart(multiPart: WebRequest.MultiPart) {
        self.mocker.recordInvocation("addMultiPart", paramList: [multiPart])
    }

    public class _executeResponse {
        var request : WebRequest!
        var response : Response!
    }
    public var executeMockedResponse : _executeResponse = _executeResponse()

    public override func execute(callback: Callback_t?) {
        if (callback != nil) {
            self.mocker.recordInvocation("execute", paramList: [callback!])

            callback!(request: self.executeMockedResponse.request, response: self.executeMockedResponse.response)
        }
        else {
            self.mocker.recordInvocation("execute", paramList: [callback])
        }
    }
}
