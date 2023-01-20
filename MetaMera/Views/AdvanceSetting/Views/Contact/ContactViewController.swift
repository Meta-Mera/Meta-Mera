//
//  ContactViewController.swift
//  MetaMera
//
//  Created by Jim on 2022/11/29.
//

import UIKit
import WebKit

class ContactViewController: UIViewController {
    
    
    @IBOutlet weak var webKit: WKWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webKit.navigationDelegate = self
        activityIndicatorView.hidesWhenStopped = true
        
        var url = URL(string: "https://forms.gle/936g11qnRRHqjNQh7")
        
        if(LocalizeKey.language.localizedString() == "jp"){
            url = URL(string: "https://forms.gle/vsFwvrkoKByTQwCd8")
        }
        
        // Do any additional setup after loading the view.
        
        let request = URLRequest(url:url!)
        DispatchQueue.main.async { [weak self] in
            self?.webKit.load(request)
        }
    }
    
    @IBAction func pushBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func startIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicatorView.startAnimating()
        }
    }

    private func stopIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicatorView.stopAnimating()
        }
    }
}

extension ContactViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        startIndicator()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopIndicator()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        stopIndicator()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        stopIndicator()
    }
}
