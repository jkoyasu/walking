//
//  PostView.swift
//  walking
//
//  Created by koyasu on 2022/01/24.
//

import UIKit

class PostView: UIViewController {

    @IBOutlet weak var postText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func post(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}