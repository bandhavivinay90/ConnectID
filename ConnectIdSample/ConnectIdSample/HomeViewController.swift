//
//  HomeViewController.swift
//  ConnectIdSample
//
//  Created by Bandhavi Vinay on 2018-01-17.
//  Copyright © 2018 Bandhavi Vinay. All rights reserved.
//

import UIKit
import AeroGearHttp
import TDConnectIosSdk

class HomeViewController: UIViewController {

    var userInfo: AnyObject?
    var oauth2Module: OAuth2Module?
    @IBOutlet weak var signedInInfo: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("oauth2Module?.isAuthorized()=\(String(describing: oauth2Module?.isAuthorized()))")

        // We can get information about the user from the SignInViewController…
        if let infoText = userInfo {
            signedInInfo.text = String(describing: infoText)
            return
        }

        // The ID token payload…
        do {
            let idTokenPayload = try oauth2Module?.getIdTokenPayload()
            signedInInfo.text = String(describing: idTokenPayload)
            return
        } catch {
            print("Failed to getIdTokenPayload: \(error)")
        }

        // Or the userInfoEndpoint.
        signedInInfo.text = "Fetching user info…"
        let http = Http()
        http.authzModule = oauth2Module
        guard let userInfoEndpoint = self.oauth2Module?.config.userInfoEndpoint else {
            self.signedInInfo.text = "Couldn't load userinfo"
            return
        }

        http.request(method: .get, path: userInfoEndpoint, completionHandler: { (response, error) in
            if let error = error {
                print("Got error when fetching userinfo. error=\(error)")
                return
            }

            self.signedInInfo.text = String(describing: response)
        })
    }

    @IBAction func signOut(_ sender: AnyObject) {
        print("Signing out…")
        oauth2Module?.revokeAccess(completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
            print("response=\(String(describing: response))")
            print("error=\(String(describing: error))")

            self.dismiss(animated: true, completion: nil)
        })
    }
}
