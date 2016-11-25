//
//  ULabelExtension.swift
//  Nwitter
//
//  Created by MAK on 11/25/16.
//  Copyright © 2016 MAK. All rights reserved.
//

import UIKit

extension UILabel {
    func setText(text: String, withHashtagColor hashtagColor: UIColor, andMentionColor mentionColor: UIColor) {
        var attrString = NSMutableAttributedString(string: text)
        
        // Call a custom set Hashtag and Mention Attributes Function
        attrString = setAttrWithName(attrName: "Hashtag", wordPrefix: "#", color: hashtagColor, text: text, attributedText: attrString)
        attrString = setAttrWithName(attrName: "Mention", wordPrefix: "@", color: mentionColor, text: text, attributedText: attrString)
        
        self.attributedText = attrString
        
        // Add tap gesture that calls a function tapRecognized when tapped
        let tapper = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized))
        addGestureRecognizer(tapper)
    }
    
    
    func setAttrWithName(attrName: String, wordPrefix: String, color: UIColor, text: String, attributedText: NSMutableAttributedString) -> NSMutableAttributedString {
        let words = text.components(separatedBy: " ")
        for word in words.filter({$0.hasPrefix(wordPrefix)}) {
            let range = (text as NSString).range(of: word)
            attributedText.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
            attributedText.addAttribute(attrName, value: 1, range: range)
            attributedText.addAttribute("Clickable", value: 1, range: range)
        }
        return attributedText
    }
    
    func tapRecognized(tapGesture: UITapGestureRecognizer) {
//        // Gets the range of word at current position
//        var point = tapGesture.location(in: self)
//        var position = closestPositionToPoint(point)
//        let range = tokenizer.rangeEnclosingPosition(position, withGranularity: .Word, inDirection: 1)
//
//        if range != nil {
//            let location = offsetFromPosition(beginningOfDocument, toPosition: range!.start)
//            let length = offsetFromPosition(range!.start, toPosition: range!.end)
//            let attrRange = NSMakeRange(location, length)
//            let word = attributedText.attributedSubstringFromRange(attrRange)
//
//            // Checks the word's attribute, if any
//            let isHashtag: AnyObject? = word.attribute("Hashtag", atIndex: 0, longestEffectiveRange: nil, inRange: NSMakeRange(0, word.length))
//            let isAtMention: AnyObject? = word.attribute("Mention", atIndex: 0, longestEffectiveRange: nil, inRange: NSMakeRange(0, word.length))
//
////            // Runs callback function if word is a Hashtag or Mention
////            if isHashtag != nil && callBack != nil {
////                callBack!(word.string, wordType.Hashtag)
////            } else if isAtMention != nil && callBack != nil {
////                callBack!(word.string, wordType.Mention)
////            }
//        }
    }
}
