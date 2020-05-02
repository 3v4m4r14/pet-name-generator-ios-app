//
//  Phrase.swift
//  Pet Name Generator
//
//  Created by Eva Maria Veitmaa on 01.05.2020.
//  Copyright © 2020 Animated Chaos. All rights reserved.
//

import Foundation

struct Phrase {

    var adjective = ""
    var noun = ""
    
    func toString() -> String {
        return adjective + " " + noun
    }
}
