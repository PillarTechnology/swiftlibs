
import Foundation

public class WebRequest : NSObject {

    public class Response : NSObject {
        var _wasSuccess : Bool
        var _responseCode : Int?
        var _errorMessage : String?
        var _headers : Dictionary<String, String> = Dictionary<String, String>()
        var _data : String!

        public init(wasSuccess : Bool) {
            _wasSuccess = wasSuccess
        }

        public func getWasSuccess() -> Bool { return _wasSuccess; }
        public func getResponseCode() -> Int? { return _responseCode }
        public func getErrorMessage() -> String? { return _errorMessage }
        public func getHeaders() -> Dictionary<String, String> { return _headers }
        public func getHeader(key : String) -> String? { return _headers[key] }
        public func getData() -> String? { return _data }

        public func setResponseCode(responseCode : Int?) { _responseCode = responseCode }
        public func setErrorMessage(errorMessage : String?) { _errorMessage = errorMessage }
        public func setHeader(header header : String, value : String) {
            _headers[header] = value
        }
        public func setData(data : String?) {
            _data = data
        }
    }

    public class MultiPart {
        public enum ContentDisposition : String {
            case INLINE = "inline"
            case ATTACHMENT = "attachment"
            case FORM_DATA = "form-data"
            case SIGNAL = "signal"
            case ALERT = "alert"
            case ICON = "icon"
            case RENDER = "render"
            case RECIPIENT_LIST_HISTORY = "recipient-list-history"
            case SESSION = "session"
            case AUTHENTICATED_IDENTITY_BODY = "aib"
            case EARLY_SESSION = "early-session"
            case RECIPIENT_LIST = "recipient-list"
            case NOTIFICATION = "notification"
            case BY_REFERENCE = "by-reference"
            case INFO_PACKAGE = "info-package"
            case RECORDING_SESSION = "recording-session"
        }

        var _contentDisposition : ContentDisposition
        var _name : String
        var _filename : String?
        var _contentType : String?
        var _data : NSData!

        var _creationDate : String?
        var _modificationDate : String?
        var _readDate : String?
        var _size : Int?
        var _voice : String?
        var _handling : String?

        internal init(contentDisposition : ContentDisposition, name : String) {
            _contentDisposition = contentDisposition
            _name = name
        }

        // NOTE:
        //  Designed to be overridden for injection.
        //      You probably do not want to use the default constructor.
        public static var newInstance : (contentDisposition : ContentDisposition, name : String) -> MultiPart = {
            (contentDisposition : ContentDisposition, name : String) -> MultiPart in
                return MultiPart(contentDisposition : contentDisposition, name : name)
        }

        public func setFilename(filename : String?) { _filename = filename }
        public func setContentType(contentType : String?) { _contentType = contentType }
        public func setData(data : String) {
            _data = data.dataUsingEncoding(NSUTF8StringEncoding)
        }
        public func setData(data : NSData) { _data = data }
        public func setCreationDate(creationDate : String?) { _creationDate = creationDate }
        public func setModificationDate(modificationDate : String?) { _modificationDate = modificationDate }
        public func setReadDate(creationDate : String?) { _readDate = creationDate }
        public func setSize(size : Int?) { _size = size }
        public func setVoice(voice : String?) { _voice = voice }
        public func setHandling(handling : String?) { _handling = handling }

        public func getContentDisposition() -> ContentDisposition { return _contentDisposition }
        public func getName() -> String { return _name }
        public func getFilename() -> String? { return _filename }
        public func getContentType() -> String? { return _contentType }
        public func getData() -> NSData { return _data }
        public func getCreationDate() -> String? { return _creationDate }
        public func getModificationDate() -> String? { return _modificationDate }
        public func getReadDate() -> String? { return _readDate }
        public func getSize() -> Int? { return _size }
        public func getVoice() -> String? { return _voice }
        public func getHandling() -> String? { return _handling }

        public func isValid() -> Bool {
            if (_filename != nil && _contentType == nil) {
                return false
            }

            return (_data != nil && _name.characters.count > 0)
        }
    }

    public typealias Callback_t = (request : WebRequest, response : Response) -> Void

    public enum HttpMethod : String {
        case GET        = "GET"
        case HEAD       = "HEAD"
        case POST       = "POST"
        case PUT        = "PUT"
        case DELETE     = "DELETE"
        case TRACE      = "TRACE"
        case CONNECT    = "CONNECT"
    }

    // NOTE:
    //  Designed to be overridden for injection.
    //      You probably do not want to use the default constructor.
    public static var newInstance : () -> WebRequest = {
        () -> WebRequest in
            return WebRequest()
    }

    // NOTE:
    //  Use the static constructor for production code.
    internal override init() {
        super.init()
    }

    internal static var _generateRandomNumber : (() -> Int)! = {
        () -> Int in
            return random()
    }

    internal class _SessionDelegate : NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
        static var newInstance : (() -> _SessionDelegate)! = {
            () -> _SessionDelegate in
                return _SessionDelegate()
        }

        internal var _followRedirects : Bool = true

        // NOTE:
        //  Use the static constructor.
        internal override init() {
            super.init()
        }

        internal func setFollowRedirects(followRedirects : Bool) {
            _followRedirects = followRedirects
        }

        // Not Implemented Signatures:
        //  func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?)
        //  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void)
        //  func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
        //  func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession)

        @objc internal func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
            if (_followRedirects) {
                completionHandler(request)
            }
            else {
                completionHandler(nil)
            }
        }
    }

    internal class func _encodeUrlString(string : String) -> String {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._*()!~")
        return string.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
    }

    internal static func _generateRandomBoundary() -> String {
        let boundaryStartLength : Int = 4
        let boundaryIdentifierLength : Int = 32
        let candidateCharacters : Array<Character> = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]

        var boundary : String = ""

        for (var i = 0; i < boundaryStartLength; ++i) {
            boundary.append("-" as Character)
        }

        for (var i = 0; i < boundaryIdentifierLength; ++i) {
            boundary.append(candidateCharacters[WebRequest._generateRandomNumber() % candidateCharacters.count])
        }

        return boundary
    }

    internal var _url : String!
    internal var _method : HttpMethod = .GET
    internal var _getParams : Dictionary<String, String> = Dictionary<String, String>()
    internal var _postParams : Dictionary<String, String> = Dictionary<String, String>()
    internal var _headers : Dictionary<String, String> = Dictionary<String, String>()
    internal var _cookies : Dictionary<String, String> = Dictionary<String, String>()
    internal var _sessionDelegate : _SessionDelegate = _SessionDelegate.newInstance()
    internal var _multiparts : Array<MultiPart> = Array<MultiPart>()


    internal static func _doesDataContainData(needle needle: NSData, haystack: NSData) -> Bool {
        return (haystack.rangeOfData(needle, options: NSDataSearchOptions.Backwards, range: NSMakeRange(0, haystack.length)).location != NSNotFound)
    }

    internal static func _stringToBytes(string : String) -> NSData {
        return NSString(string: string).dataUsingEncoding(NSUTF8StringEncoding)!
    }

    // Description:
    //  If the paramValue is not nil, the key/value pair will be appended to multiPartBody, prepended with a "; "
    internal func _appendOptionalParam(multiPartBody : NSMutableData, paramKey : String, paramValue : String?) {
        if (paramValue != nil) {
            multiPartBody.appendData(WebRequest._stringToBytes("; \(paramKey)=\"\(paramValue!)\""))
        }
    }

    public func setUrl(url : String) { _url = url }

    public func setMethod(method : HttpMethod) { _method = method }

    public func setHeader(header header : String, value : String) { _headers[header] = value }

    public func setFollowRedirects(followRedirects : Bool) { _sessionDelegate.setFollowRedirects(followRedirects) }

    public func setGetParam(key key : String, value : String) { _getParams[key] = value }

    public func setPostParam(key key : String, value : String) {
        _multiparts.removeAll()

        _postParams[key] = value
    }

    public func addCookie(key key : String, value : String?) {
        if (value == nil) {
            _cookies.removeValueForKey(key)
        }
        else {
            _cookies[key] = value
        }
    }

    public func addCookie(keyValuePair : String) {
        if (keyValuePair.containsString("=")) {
            var keyValues : Array<String> = Util.splitString(deliminator: "=", string: keyValuePair, maxCount: 1)
            _cookies[keyValues[0]] = keyValues[1]
        }
    }

    public func addMultiPart(multiPart : MultiPart) {
        _postParams.removeAll()

        if (multiPart.isValid()) {
            _multiparts.append(multiPart)
        }
        else {
            print("NOTICE: Invalid multipart.")
        }
    }

    internal func _generatePostBody() -> String {
        var postBody : String = ""
        for key : String in _postParams.keys {
            let value : String = _postParams[key]!
            postBody.appendContentsOf("\(WebRequest._encodeUrlString(key))=\(WebRequest._encodeUrlString(value))&")
        }
        postBody.removeAtIndex(postBody.endIndex.predecessor()) // Remove the last ampersand...
        return postBody
    }

    internal func _appendGetParams(var url : String) -> String {
        if (!url.containsString("?")) {
            url.appendContentsOf("?")
        }

        for key : String in _getParams.keys {
            let value : String = _getParams[key]!
            url.appendContentsOf("\(WebRequest._encodeUrlString(key))=\(WebRequest._encodeUrlString(value))&")
        }
        url.removeAtIndex(url.endIndex.predecessor()) // Remove the last ampersand...

        return url
    }

    // NOTE:
    //  Generates a MultiPart boundary that is gauranteed to not exist within any current multiPart data.
    internal func _generateMultiPartSafeBoundary() -> String {
        var boundary = WebRequest._generateRandomBoundary()
        var boundaryIsValid : Bool = false
        while (!boundaryIsValid) {
            boundaryIsValid = true

            for multiPart in _multiparts {
                let needle : NSData = boundary.dataUsingEncoding(NSUTF8StringEncoding)!
                if (WebRequest._doesDataContainData(needle: needle, haystack: multiPart.getData())) {
                    boundaryIsValid = false
                }
            }

            if (!boundaryIsValid) {
                boundary = WebRequest._generateRandomBoundary()
            }
        }

        return boundary
    }

    internal func _generateMultiPartBody(boundary : String) -> NSData {
        let multiPartBody : NSMutableData = NSMutableData()
        let preBoundaryBytes : NSData = ("--" as String).dataUsingEncoding(NSUTF8StringEncoding)!
        let newlineDeliminator : NSData = NSString(string: "\r\n").dataUsingEncoding(NSUTF8StringEncoding)!
        let boundaryBytes : NSData = boundary.dataUsingEncoding(NSUTF8StringEncoding)!
        for multiPart in _multiparts {
            multiPartBody.appendData(preBoundaryBytes)
            multiPartBody.appendData(boundaryBytes)
            multiPartBody.appendData(newlineDeliminator)

            // Set Content-Disposition and Optional-Params
            multiPartBody.appendData(WebRequest._stringToBytes("Content-Disposition: \(multiPart.getContentDisposition().rawValue)"))
            multiPartBody.appendData(WebRequest._stringToBytes("; name=\"\(multiPart.getName())\""))

            let size : Int? = multiPart.getSize()
            _appendOptionalParam(multiPartBody, paramKey: "size",               paramValue: (size != nil ? String(size!) : nil))
            _appendOptionalParam(multiPartBody, paramKey: "filename",           paramValue: multiPart.getFilename())
            _appendOptionalParam(multiPartBody, paramKey: "creation-date",      paramValue: multiPart.getCreationDate())
            _appendOptionalParam(multiPartBody, paramKey: "modification-date",  paramValue: multiPart.getModificationDate())
            _appendOptionalParam(multiPartBody, paramKey: "read-date",          paramValue: multiPart.getReadDate())
            _appendOptionalParam(multiPartBody, paramKey: "voice",              paramValue: multiPart.getVoice())
            _appendOptionalParam(multiPartBody, paramKey: "handling",           paramValue: multiPart.getHandling())

            multiPartBody.appendData(newlineDeliminator)

            // Set Content-Type
            let contentType : String? = multiPart.getContentType()
            if (contentType != nil) {
                multiPartBody.appendData(WebRequest._stringToBytes("Content-Type: \(contentType!)"))
                multiPartBody.appendData(newlineDeliminator)
            }

            multiPartBody.appendData(newlineDeliminator)

            multiPartBody.appendData(multiPart.getData())

            multiPartBody.appendData(newlineDeliminator)
        }

        // Closing Boundary...
        multiPartBody.appendData(preBoundaryBytes)
        multiPartBody.appendData(boundaryBytes)
        multiPartBody.appendData(preBoundaryBytes)
        multiPartBody.appendData(newlineDeliminator)

        return multiPartBody
    }

    // TODO: This should escape semicolons, and possible the following additional characters: ()<>@,;:\"/[]?={} ( src: http://goo.gl/EMOh9d )
    internal func _generateCookieHeader() -> String {
        var cookieHeader : String = ""
        for cookieKey : String in _cookies.keys {
            let cookieValue : String = _cookies[cookieKey]!
            cookieHeader.appendContentsOf("\(cookieKey)=\(cookieValue); ")
        }
        cookieHeader.removeAtIndex(cookieHeader.endIndex.predecessor()) // Remove the last space...
        cookieHeader.removeAtIndex(cookieHeader.endIndex.predecessor()) // Remove the last semicolon...
        return cookieHeader
    }

    // NOTE:
    //  Many of the components used in this function aren't able to be mocked.
    //  Therefore, this function is left untested.
    public func execute(callback : Callback_t?) {
        var url : String = _url

        // Handle Get-Params
        if (_getParams.count > 0) {
            url = _appendGetParams(url)
        }

        // Handle Post-Params
        var postBody : String? = nil
        if (_method == .POST && _postParams.count > 0) {
            postBody = _generatePostBody()
        }

        // Handle Attachments (MultiParts)
        var multiPartBody : NSData? = nil
        if (_multiparts.count > 0) {
            let boundary : String = _generateMultiPartSafeBoundary()
            multiPartBody = _generateMultiPartBody(boundary)

            _headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
            _headers["Content-Length"] = "\(multiPartBody!.length)"
        }

        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = _method.rawValue

        // NOTE:
        //  Be sure this block executes before the headers are added to the request.
        if (_cookies.count > 0) {
            _headers["Cookie"] = _generateCookieHeader()
        }

        // Handle Headers
        if (_headers.count > 0) {
            for headerKey : String in _headers.keys {
                let headerValue : String = _headers[headerKey]!
                request.setValue(headerValue, forHTTPHeaderField: headerKey)
            }
        }

        // Post Body
        if (postBody != nil) {
            request.HTTPBody = postBody!.dataUsingEncoding(NSUTF8StringEncoding)
        }
        else if (multiPartBody != nil) {
            request.HTTPBody = multiPartBody!
        }

        // Set the SessionDelegate (for FollowsRedirect)
        let session : NSURLSession! = NSURLSession(
            configuration:  NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:       _sessionDelegate,
            delegateQueue:  NSOperationQueue()
        )

        // Create the DataTask from the Request
        let dataTask : NSURLSessionDataTask = session.dataTaskWithRequest(
            request,
            completionHandler: {
                (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
                    let wasSuccess : Bool = (error == nil && data != nil && response != nil)
                    let webRequestResponse : Response = Response(wasSuccess: wasSuccess)

                    let httpUrlResponse : NSHTTPURLResponse? = response as? NSHTTPURLResponse

                    if (wasSuccess && httpUrlResponse != nil) {
                        let headers : Dictionary<NSObject, AnyObject> = httpUrlResponse!.allHeaderFields
                        for headerTuple in headers {
                            let header : String! = headerTuple.0 as? String
                            let value : String! = headerTuple.1 as? String

                            if (header != nil && value != nil) {
                                webRequestResponse.setHeader(header: header, value: value)
                            }
                        }

                        if (data != nil) {
                            webRequestResponse.setData(NSString(data: data!, encoding: NSUTF8StringEncoding) as? String)
                        }
                    }
                    else {
                        webRequestResponse.setErrorMessage(error!.localizedDescription)
                    }

                    if (httpUrlResponse != nil) {
                        webRequestResponse.setResponseCode(httpUrlResponse!.statusCode)
                    }

                    callback?(request: self, response: webRequestResponse)
            }
        )

        // Execute the Request
        dataTask.resume()
    }
}
