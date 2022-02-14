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
        postText.layer.borderColor = UIColor.gray.cgColor
        postText.layer.borderWidth = 1
        postText.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func post(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
