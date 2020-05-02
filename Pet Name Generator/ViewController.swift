//
//  ViewController.swift
//  Pet Name Generator
//
//  Created by Eva Maria Veitmaa on 01.05.2020.
//  Copyright © 2020 Animated Chaos. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HomeModelDelegate {

    @IBOutlet weak var petNameLabel: UILabel!
    
    var homeModel = HomeModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        //Initiate calling the items download
        homeModel.getPetNamePhrase()
        homeModel.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    func itemsDownloaded(phrase: Phrase) {
        petNameLabel.text = phrase.toString()
    }
    
    @objc func onTap(_ gesture: UIGestureRecognizer) {
        guard gesture.view != nil else { return }
        
        if (gesture.state == .ended) {
            homeModel.getPetNamePhrase()
        }
    }
}

