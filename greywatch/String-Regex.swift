//
//  String-Regex.swift
//  greywatch
//
//  Created by boB Rudis on 3/28/21.
//

import Foundation

extension String{
  
  func groups(pattern: String) -> [String] {
    
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
      let all = NSRange(location: 0, length: count)
      var matches = [String]()
      regex.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all) {
        (result : NSTextCheckingResult?, _, _) in
        if let r = result {
          let nsstr = self as NSString
          let result = nsstr.substring(with: r.range) as String
          matches.append(result)
        }
      }
      return matches
    } catch {
      return([String]())
    }
    
  }
  
  func matches(_ regex: String) -> Bool {
    return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
  }
  
}

extension Array where Element == String {
  func notin(_ list: [String]) -> [String] {
    return(Array(Set(self).subtracting(list)))
  }
}

extension Sequence where Iterator.Element: Hashable {
  func unique() -> [Iterator.Element] {
    var seen: Set<Iterator.Element> = []
    return filter { seen.insert($0).inserted }
  }
}
