
import XCTest
@testable import SwiftLibs

class WebRequestTests: XCTestCase {
    var _subject : WebRequest!
    var _mockedSessionDelegate : MockWebRequestSessionDelegate!

    override func setUp() {
        super.setUp()

        _mockedSessionDelegate = MockWebRequestSessionDelegate.mockConstructor()
        MockWebRequest.mockRandomFunction(nil)

        _subject = SwiftLibs.WebRequest.newInstance()
    }

    override func tearDown() {
        MockWebRequest.restoreRandomFunction()
        MockWebRequestSessionDelegate.restoreConstructor()

        super.tearDown()
    }

    func testStaticConstructor() {
        // Setup

        // Action

        // Assert
        XCTAssertNotNil(_subject)
    }

    func testSessionDelegateIgnoresRedirectsWhenRedirectsDisabled() {
        // Setup
        let shouldFollowRedirects : Bool = false
        let subject : WebRequest._SessionDelegate = WebRequest._SessionDelegate()
        let urlSession : NSURLSession = NSURLSession()
        let sessionTask : NSURLSessionTask = NSURLSessionTask()
        let urlRequest : NSURLRequest = NSURLRequest()
        let urlResponse : NSHTTPURLResponse = NSHTTPURLResponse()

        var completionHandlerParameter : NSURLRequest?
        let completionHandler : ((request : NSURLRequest?) -> Void)! = {
            (request : NSURLRequest?) -> Void in
                completionHandlerParameter = request
        }

        subject.setFollowRedirects(shouldFollowRedirects)

        // Action
        subject.URLSession(urlSession, task: sessionTask, willPerformHTTPRedirection: urlResponse, newRequest: urlRequest, completionHandler: completionHandler)

        // Assert
        XCTAssertNil(completionHandlerParameter, "Completion handler must be invoked with nil when not following redirects.")
    }

    func testSessionDelegateFollowsRedirectsWhenRedirectsEnabled() {
        // Setup
        let shouldFollowRedirects : Bool = true
        let subject : WebRequest._SessionDelegate = WebRequest._SessionDelegate()
        let urlSession : NSURLSession = NSURLSession()
        let sessionTask : NSURLSessionTask = NSURLSessionTask()
        let urlRequest : NSURLRequest = NSURLRequest()
        let urlResponse : NSHTTPURLResponse = NSHTTPURLResponse()

        var completionHandlerParameter : NSURLRequest?
        let completionHandler : ((request : NSURLRequest?) -> Void)! = {
            (request : NSURLRequest?) -> Void in
                completionHandlerParameter = request
        }

        subject.setFollowRedirects(shouldFollowRedirects)

        // Action
        subject.URLSession(urlSession, task: sessionTask, willPerformHTTPRedirection: urlResponse, newRequest: urlRequest, completionHandler: completionHandler)

        // Assert
        XCTAssertEqual(completionHandlerParameter, urlRequest, "Completion handler must be invoked with the original request when following redirects.")
    }

    func testSetPostParamClearsMultiParts() {
        // Setup
        _subject._multiparts.append(WebRequest.MultiPart(contentDisposition: .INLINE, name: "multipart"))

        // Action
        _subject.setPostParam(key: "key", value: "value")

        // Assert
        XCTAssertEqual(_subject._multiparts.count, 0, "Setting a post param must clear out multiparts.")
    }

    func testAddMultipartClearsPostParams() {
        // Setup
        _subject._postParams["key"] = "value"

        // Action
        _subject.addMultiPart(WebRequest.MultiPart(contentDisposition: .INLINE, name: "multipart"))

        // Assert
        XCTAssertEqual(_subject._postParams.count, 0, "Adding a multipart object must clear out post params.")
    }

    func testAddInvalidMultipartDoesNotAppendMultiPart() {
        // Setup
        let multiPart : WebRequest.MultiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "multipart")

        // Action
        _subject.addMultiPart(multiPart)

        // Assert
        XCTAssertEqual(_subject._multiparts.count, 0, "Adding an invalid multipart object does not append to multipart list.")
    }

    func testAddValidMultipartAppendsMultiPart() {
        // Setup
        let multiPart : WebRequest.MultiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "multipart")
        multiPart.setData("0123456789ABCDEFFEDCBA9876543210".dataUsingEncoding(NSUTF8StringEncoding)!)

        // Action
        _subject.addMultiPart(multiPart)

        // Assert
        XCTAssertEqual(_subject._multiparts.count, 1, "Adding a valid multipart object appends it to the multipart list.")
    }

    func testGenerateBoundary() {
        // Setup
        let minLength : Int = 36
        let maxLength : Int = 36
        let validCharacters : NSCharacterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        let boundaryPrefix : String = "----"
        let randomBoundary : String!

        // Action
        randomBoundary = WebRequest._generateRandomBoundary()

        // Assert
        XCTAssertLessThanOrEqual(randomBoundary.characters.count, maxLength, "Random boundary is larger than its max length.")
        XCTAssertGreaterThanOrEqual(randomBoundary.characters.count, minLength, "Random boundary is smaller than its min length.")
        XCTAssertEqual(NSString(string: randomBoundary).substringToIndex(boundaryPrefix.characters.count), boundaryPrefix, "Random boundary does not start with an expected prefix.")
        XCTAssertNil(NSString(string: randomBoundary).substringFromIndex(boundaryPrefix.characters.count).rangeOfCharacterFromSet(validCharacters.invertedSet), "Random boundary (after the prefix) contains invalid characters.")
    }

    func testGenerateBoundaryWithLargerRandomSeed() {
        // Setup
        var i : Int = 1024 // 1024 % 36 = 8 (make sure the seed wraps around the boundary character-set)
        MockWebRequest.mockRandomFunction({
            () -> Int in
                return i++
        })

        let minLength : Int = 36
        let maxLength : Int = 36
        let validCharacters : NSCharacterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        let boundaryPrefix : String = "----"
        let randomBoundary : String!

        // Action
        randomBoundary = WebRequest._generateRandomBoundary()

        // Assert
        XCTAssertLessThanOrEqual(randomBoundary.characters.count, maxLength, "Random boundary is larger than its max length.")
        XCTAssertGreaterThanOrEqual(randomBoundary.characters.count, minLength, "Random boundary is smaller than its min length.")
        XCTAssertEqual(NSString(string: randomBoundary).substringToIndex(boundaryPrefix.characters.count), boundaryPrefix, "Random boundary does not start with an expected prefix.")
        XCTAssertNil(NSString(string: randomBoundary).substringFromIndex(boundaryPrefix.characters.count).rangeOfCharacterFromSet(validCharacters.invertedSet), "Random boundary (after the prefix) contains invalid characters.")
    }

    func testMultiPartIsValidWhenFilenameIsNilAndDataIsSet() {
        // Setup
        let subject : WebRequest.MultiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "name")
        subject.setData("0123456789ABCDEFFEDCBA9876543210".dataUsingEncoding(NSUTF8StringEncoding)!)
        let isValid : Bool!

        // Action
        isValid = subject.isValid()

        // Assert
        XCTAssertTrue(isValid!, "isValid must be true if data is set.")
    }

    func testMultiPartIsInvalidWhenNameLengthIsZero() {
        // Setup
        let subject : WebRequest.MultiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "")
        subject.setData("0123456789ABCDEFFEDCBA9876543210".dataUsingEncoding(NSUTF8StringEncoding)!)
        let isValid : Bool!

        // Action
        isValid = subject.isValid()

        // Assert
        XCTAssertFalse(isValid!, "isValid must be false if name is empty.")
    }

    func testMultiPartIsInvalidWhenDataIsNotSet() {
        // Setup
        let subject : WebRequest.MultiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "name")
        let isValid : Bool!

        // Action
        isValid = subject.isValid()

        // Assert
        XCTAssertFalse(isValid!, "isValid must be false if a data has not been set.")
    }

    func testMultiPartIsInvalidWhenFilenameIsSetButContentTypeIsNotSet() {
        // Setup
        let subject : WebRequest.MultiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "name")
        subject.setData("0123456789ABCDEFFEDCBA9876543210".dataUsingEncoding(NSUTF8StringEncoding)!)
        subject.setFilename("filename")
        let isValid : Bool!

        // Action
        isValid = subject.isValid()

        // Assert
        XCTAssertFalse(isValid!, "isValid must be false if filename is set but content type is not.")
    }

    func testMultiPartIsValidWhenFilenameAndContentTypeIsSet() {
        // Setup
        let subject : WebRequest.MultiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "name")
        subject.setData("0123456789ABCDEFFEDCBA9876543210".dataUsingEncoding(NSUTF8StringEncoding)!)
        subject.setFilename("filename")
        subject.setContentType("application/json")
        let isValid : Bool!

        // Action
        isValid = subject.isValid()

        // Assert
        XCTAssertTrue(isValid!, "isValid must be true if filename and content type is set.")
    }

    func testEncodeUrlString() {
        // Setup
        let string : String = "~!@#$%^&*()`1234567890_+-=?><;'\":|}{[]ABCDEFfedc bazzs,.\r\n\t"
        let expectedEncodedString : String = "~!%40%23%24%25%5E%26*()%601234567890_%2B-%3D%3F%3E%3C%3B%27%22%3A%7C%7D%7B%5B%5DABCDEFfedc%20bazzs%2C.%0D%0A%09"
        let encodedString : String!

        // Action
        encodedString = WebRequest._encodeUrlString(string)

        // Assert
        XCTAssertEqual(encodedString, expectedEncodedString, "encodeUrlString failed to encode a character.")
    }

    func testGeneratePostBody() {
        // Setup
        _subject.setPostParam(key: "key", value: "value one!")
        _subject.setPostParam(key: "key2", value: "value&two")
        let expectedPostBody : String = "key=value%20one!&key2=value%26two"

        var postBody : String!

        // Action
        postBody = _subject._generatePostBody()

        // Assert
        XCTAssertEqual(postBody, expectedPostBody)
    }

    func testAppendGetParamsWithNoQuestionMarkInUrl() {
        // Setup
        let url : String = "https://www.google.com"
        _subject.setGetParam(key: "key", value: "value one!")
        _subject.setGetParam(key: "key2", value: "value&two")
        let expectedGetBody : String = "\(url)?key=value%20one!&key2=value%26two"

        var getBody : String!

        // Action
        getBody = _subject._appendGetParams(url)

        // Assert
        XCTAssertEqual(getBody, expectedGetBody)
    }

    func testAppendGetParamsWithAnExistingQuestionMarkInUrl() {
        // Setup
        let url : String = "https://www.google.com?"
        _subject.setGetParam(key: "key", value: "value one!")
        _subject.setGetParam(key: "key2", value: "value&two")
        let expectedGetBody : String = "\(url)key=value%20one!&key2=value%26two"

        var getBody : String!

        // Action
        getBody = _subject._appendGetParams(url)

        // Assert
        XCTAssertEqual(getBody, expectedGetBody)
    }

    func testGenerateMultiPartBoundaryWithBoundaryNotExistingInMultiparts() {
        // Setup
        var i : Int = 0
        MockWebRequest.mockRandomFunction({
            () -> Int in
                if (i < 32) {
                    i += 1
                    return 0
                }

                return i++ - 32
        })
        let expectedBoundary : String = "----AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" // Determined by our mockRandomFunction
        let multiPart : WebRequest.MultiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "name")
        multiPart.setData("0123456789ABCDEFFEDCBA9876543210".dataUsingEncoding(NSUTF8StringEncoding)!)
        _subject.addMultiPart(multiPart)

        var boundary : String!

        // Action
        boundary = _subject._generateMultiPartSafeBoundary()

        // Assert
        XCTAssertEqual(boundary, expectedBoundary)
    }

    func testGenerateMultiPartBoundaryWithBoundaryExistingInMultiparts() {
        // Setup
        var i : Int = 0
        MockWebRequest.mockRandomFunction({
            () -> Int in
                if (i < 32) {
                    i += 1
                    return 0
                }

                return i++ - 32
        })
        let invalidBoundary : String = "----AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" // Determined by our mockRandomFunction
        let multiPart : WebRequest.MultiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "name")
        multiPart.setData(invalidBoundary.dataUsingEncoding(NSUTF8StringEncoding)!)
        _subject.addMultiPart(multiPart)

        var boundary : String!

        // Action
        boundary = _subject._generateMultiPartSafeBoundary()
        print(boundary)

        // Assert
        XCTAssertNotEqual(boundary, invalidBoundary)
    }

    func testGenerateMultiPartBodyWithOnePart() {
        // Setup
        let boundary : String = "----ABCDEFGHIJKLMNOPQRSTUVWXYZ012345"

        var multiPart : WebRequest.MultiPart!

        multiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "wizard01")
        multiPart.setData("Harry Potter".dataUsingEncoding(NSUTF8StringEncoding)!)
        multiPart.setSize(12)
        multiPart.setCreationDate("2015-01-01")
        multiPart.setModificationDate("2015-01-01")
        multiPart.setReadDate("2015-01-01")
        multiPart.setVoice("voice")
        multiPart.setHandling("handling")
        _subject.addMultiPart(multiPart)

        let expectedBody : String = "------ABCDEFGHIJKLMNOPQRSTUVWXYZ012345\r\nContent-Disposition: inline; name=\"wizard01\"; size=\"12\"; creation-date=\"2015-01-01\"; modification-date=\"2015-01-01\"; read-date=\"2015-01-01\"; voice=\"voice\"; handling=\"handling\"\r\n\r\nHarry Potter\r\n------ABCDEFGHIJKLMNOPQRSTUVWXYZ012345--\r\n"

        var multiPartBody : NSData!

        // Action
        multiPartBody = _subject._generateMultiPartBody(boundary)

        // Assert
        XCTAssertEqual(multiPartBody, expectedBody.dataUsingEncoding(NSUTF8StringEncoding))
    }

    func testGenerateMultiPartBodyWithMultipleParts() {
        // Setup
        let boundary : String = "----ABCDEFGHIJKLMNOPQRSTUVWXYZ012345"

        var multiPart : WebRequest.MultiPart!

        multiPart = WebRequest.MultiPart(contentDisposition: .INLINE, name: "wizard01")
        multiPart.setData("Harry Potter".dataUsingEncoding(NSUTF8StringEncoding)!)
        _subject.addMultiPart(multiPart)

        multiPart = WebRequest.MultiPart(contentDisposition: .ATTACHMENT, name: "wizard02")
        multiPart.setFilename("attachment.txt")
        multiPart.setContentType("text/plain")
        multiPart.setData("Ronald Weasley".dataUsingEncoding(NSUTF8StringEncoding)!)
        _subject.addMultiPart(multiPart)

        let expectedBody : String = "------ABCDEFGHIJKLMNOPQRSTUVWXYZ012345\r\nContent-Disposition: inline; name=\"wizard01\"\r\n\r\nHarry Potter\r\n------ABCDEFGHIJKLMNOPQRSTUVWXYZ012345\r\nContent-Disposition: attachment; name=\"wizard02\"; filename=\"attachment.txt\"\r\nContent-Type: text/plain\r\n\r\nRonald Weasley\r\n------ABCDEFGHIJKLMNOPQRSTUVWXYZ012345--\r\n"

        var multiPartBody : NSData!

        // Action
        multiPartBody = _subject._generateMultiPartBody(boundary)

        // Assert
        XCTAssertEqual(multiPartBody, expectedBody.dataUsingEncoding(NSUTF8StringEncoding))
    }

    func testGenerateCookieHeader() {
        // Setup
        _subject.addCookie(key: "key", value: "value one")
        _subject.addCookie("key2=value two")
        let expectedHeader : String = "key=value one; key2=value two"

        var header : String!

        // Action
        header = _subject._generateCookieHeader()
        print(header)

        // Assert
        XCTAssertEqual(header, expectedHeader)
    }
}
