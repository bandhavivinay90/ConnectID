//
//  ViewController.swift
//  ConnectIdSample
//
//  Created by Bandhavi Vinay on 2018-01-16.
//  Copyright © 2018 Bandhavi Vinay. All rights reserved.
//

import UIKit
import AeroGearHttp
import TDConnectIosSdk

class ViewController: UIViewController {

    var hasAppeared = false
    var performingingSegue = false
    var oauth2Module: OAuth2Module?
    let config = TelenorConnectConfig(clientId: "tnse-testclient-ios",
                                      redirectUrl: "tnse-testclient-ios://connect/oauth2callback",
                                      useStaging: true,
                                      scopes: ["profile", "openid", "email"],
                                      accountId: "tnse-testclient-ios",
                                      webView:true,
                                      optionalParams: ["ui_locales": "no", "acr_values": "2"],
                                      isPublicClient: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        oauth2Module = AccountManager.getAccountBy(config: config) ?? AccountManager.addAccountWith(config: self.config, moduleClass: TelenorConnectOAuth2Module.self)
        print("oauth2Module!.isAuthorized()=\(oauth2Module!.isAuthorized())")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hasAppeared = false
        performingingSegue = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Note: The method will be called after (Safari) WebView completes logging in the user
        if oauth2Module!.isAuthorized() && !performingingSegue {
            performingingSegue = true
            self.performSegue(withIdentifier: "signedIn", sender: nil)
        }
        hasAppeared = true
    }

    @IBAction func signInAction(_ sender: AnyObject) {
        guard let oauth2Module = self.oauth2Module else {
            return
        }

        if oauth2Module.isAuthorized() {
            self.performSegue(withIdentifier: "signedIn", sender: nil)
            return
        }

        oauth2Module.requestAccess {(accessToken: AnyObject?, error: NSError?) -> Void in
            guard let accessToken = accessToken else {
                print("error=\(String(describing: error))")
                return
            }

            print("accessToken=\(accessToken)")
            if self.hasAppeared && !self.performingingSegue {
                self.performingingSegue = true
                self.performSegue(withIdentifier: "signedIn", sender: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "signedIn") {
            let homeViewController = segue.destination as! HomeViewController
            homeViewController.oauth2Module = oauth2Module
        }
    }

}

