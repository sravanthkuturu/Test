//
//  ViewController.swift
//  ReusableLibrary
//
//  Created by Sravanth Kuturu on 20/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var labelCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapToMakeAPICall(_ sender: UIButton) {
        
        self.labelCount.text = "Please wait...."
        ItunesService.shared.processItunesServiceAPIRequest(baseURL: AppConstant.baseURL, id: "909253") { [weak self] (model, error) in
            guard let model = model,
                let count = model.resultCount else {
                DispatchQueue.main.async {
                    self?.labelCount.text = "Result count: 0"
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.labelCount.text = "Result count: \(count)"
            }
            
            
        }
        
    }
    
}

