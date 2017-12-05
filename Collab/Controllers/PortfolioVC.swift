//
//  PortfolioVC.swift
//  Collab
//
//  Created by Apple on 26/10/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class PortfolioVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var portfolioURLString : URL?
    let errorHTMLString = "<html><body><p class='title' style='font-family:verdana; color:black; font-size:200%; text-align:center;'>Page Not Found</p><p class='message' style='font-family:verdana; color:gray; font-size:100%; text-align:center;'>The link you clicked may be broken or the page may have been removed.</p></body></html>"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (portfolioURLString != nil){
            if UIApplication.shared.canOpenURL(portfolioURLString!){
                AppManager.sharedInstance.showHud(showInView: self.view, label: "Loading....")
                self.webView.loadRequest(NSURLRequest(url: portfolioURLString!) as URLRequest)
            }else{
                webView.loadHTMLString(errorHTMLString, baseURL: nil)
                //self.navigationController?.popViewController(animated: true)
            }
        }else{
            webView.loadHTMLString(errorHTMLString, baseURL: nil)
            //self.navigationController?.popViewController(animated: true)
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK:
    //MARK: - UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        AppManager.sharedInstance.hidHud()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.webViewDidFinishLoad(webView)
        AppManager.sharedInstance.hidHud()
       
        
        webView.loadHTMLString(errorHTMLString, baseURL: nil)
        
        //self.navigationController?.popViewController(animated: true)
    }

}
