//
//  HomeModel.swift
//  Pet Name Generator
//
//  Created by Eva Maria Veitmaa on 01.05.2020.
//  Copyright © 2020 Animated Chaos. All rights reserved.
//

import UIKit

protocol HomeModelDelegate {
    func itemsDownloaded(phrase:Phrase)
}

class HomeModel: NSObject {
    
    var delegate:HomeModelDelegate?

    func getPetNamePhrase() {
        print("Getting pet name phrase...")
        
        var adjLen = 0
        var nounLen = 0
        var adjective = ""
        var noun = ""
        
        let operationQueue = OperationQueue()
        
        let pollingForListSizes = BlockOperation {
            print("polling for size")
            // Get adjective table length
            adjLen = self.getLen(urlString: "https://evamaria.info/api/petname/adjective/size.php")
            
            // Get noun table length
            nounLen = self.getLen(urlString: "https://evamaria.info/api/petname/noun/size.php")
        }
    
        let pollingForWords = BlockOperation {
            print("polling for words")
            // Hit the adjective web service URL
            adjective = self.getRandomWord(type: "adjective", collectionSize: adjLen)
            
            // Hit the noun web service URL
            noun = self.getRandomWord(type: "noun", collectionSize: nounLen)
        }
        
        print("Lengths: ", adjLen)
        
        let passingPhraseToViewController = BlockOperation {
            print("Phrase is ", adjective+noun)
            // Parse it into a Phrase struct
            let phrase = Phrase(adjective: adjective, noun: noun)
            print(phrase.toString())
            // Notify the view controller and pass the data back
            DispatchQueue.main.async {
                self.delegate?.itemsDownloaded(phrase: phrase)
            }
            
        }
        
        pollingForWords.addDependency(pollingForListSizes)
        passingPhraseToViewController.addDependency(pollingForWords)
        operationQueue.addOperation(pollingForListSizes)
        operationQueue.addOperation(pollingForWords)
        operationQueue.addOperation(passingPhraseToViewController)
    }
    
    func getRandomWord(type:String, collectionSize:Int) -> String {
        var word = ""
        let id = getRandomIndex(max: collectionSize)
        print("ID: ", id)
        
        let urlString = "https://evamaria.info/api/petname/\(type)/readone.php?id=\(id)"
        print("URL: ", urlString)
        // Hit the web service url and download JSON data
        guard let url = URL(string: urlString) else {
            print("oops")
            return word }
        print("Kaka")
        let group2 = DispatchGroup()
        group2.enter()
        print("noku")
        //Create a URL session
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let data = data {
                //Succeeded
                print("I'm here banananana")
                word = self.parseWordJSON(data: data)
                group2.leave()
            }
            else {
                print("An error occurred when polling for ", type)
            }
            }).resume()
        group2.wait()
        print(word)
        return word
    }
    
    func parseWordJSON(data:Data) -> String {
        do {
            let wordItem = try JSONDecoder().decode(Word.self, from: data)
            return wordItem.word
        } catch let jsonERR {
            print("An error occurred at parsing JSON: ", jsonERR)
        }
        return ""
    }
    
    func getLen(urlString:String) -> Int {
        var length = 0
        
        // Hit the web service url and download JSON data
        guard let url = URL(string: urlString) else { return length }
        
        let group = DispatchGroup()
        group.enter()
        
        //Create a URL session
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let data = data {
                //Succeeded
                length = self.parseLenJSON(data: data)
                group.leave()
            }
            else {
                //Error occurred
                print("An error occurred when polling for length iykwim")
            }
            }).resume()
        group.wait()
        print("Size: ", length)
        return length
    }
    
    func parseLenJSON(data:Data) -> Int {
        do {
            let collection = try JSONDecoder().decode(CollectionSize.self, from: data)
            return collection.size
        } catch let jsonERR {
            print("An error occurred at parsing JSON: ", jsonERR)
        }
        return 0
    }
    
    func getRandomIndex(max:Int) -> Int {
        return Int.random(in: 1...max)
    }
}
