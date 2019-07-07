//
//  WebViewController.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 7/6/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    
    var link = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var url = URL(string: link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        webView.load(URLRequest(url: url!))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
