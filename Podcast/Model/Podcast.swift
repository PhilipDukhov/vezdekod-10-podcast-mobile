//
//  Podcast.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/16/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import Foundation

struct Podcast {
    enum Kind {
        case trailer
        case regular
    }
    enum Visibility {
        case all
        case friends
        case `private`
    }
    var title: String
    var description: String
    var audioFile: AudioFile
    var malformContent: Bool
    var excludeFromExport: Bool
    var trailer: Bool
    var visibility: Visibility
}
