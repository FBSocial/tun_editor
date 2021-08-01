//
//  EditorType.swift
//  tun_editor
//
//  Created by Jeffrey Wu on 2021/7/30.
//

import Foundation

enum TextType: String {
    case normal = "normal"
    case headline1 = "header1"
    case headline2 = "header2"
    case headline3 = "header3"
    case listBullet = "list-bullet"
    case listOrdered = "list-ordered"
    case divider = "divider"
    case quote = "blockquote"
    case codeBlock = "code-block"
    
    func viewTag() -> Int {
        switch self {
        case .normal:
            return 0
        case .headline1:
            return 1
        case .headline2:
            return 2
        case .headline3:
            return 3
        case .listBullet:
            return 4
        case .listOrdered:
            return 5
        case .divider:
            return 6
        case .quote:
            return 7
        case .codeBlock:
            return 8
        }
    }
}

enum TextStyle: String {
    case bold = "bold"
    case italic = "italic"
    case underline = "underline"
    case strikeThrough = "strike"
    
    func viewTag() -> Int {
        switch self {
        case .bold:
            return 0
        case .italic:
            return 1
        case .underline:
            return 2
        case .strikeThrough:
            return 3
        }
    }
}
