
import Foundation

public class Util {
    public static func dataFromHexadecimalString(input : String) -> NSData? {
        let trimmedString = input
        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)

        let found = regex.firstMatchInString(trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count))
        if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
            return nil
        }

        let data = NSMutableData(capacity: trimmedString.characters.count / 2)

        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [UInt8], length: 1)
        }

        return data
    }

    public class func splitString(deliminator deliminator : String, string: String, maxCount : Int?) -> Array<String> {
        let elements : Array<String> = NSString(string: string).componentsSeparatedByString(deliminator)

        if (maxCount == nil) {
            return elements
        }
        else {
            var returnElements : Array<String> = Array<String>()
            var lastElement : String = ""
            var i : Int = 0
            for substring : String in elements {

                if (i == maxCount) {
                    lastElement.appendContentsOf(substring)
                }
                else if (i >= maxCount) {
                    lastElement.appendContentsOf("\(deliminator)\(substring)")
                }
                else {
                    returnElements.append(substring)
                }

                ++i
            }

            returnElements.append(lastElement)
            return returnElements
        }
    }
}
