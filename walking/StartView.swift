//
//  StartView.swift
//  walking
//
//  Created by koyasu on 2022/01/06.
//

import UIKit
import MSAL
import YammerSDK

class StartView: UIViewController {
    //全情報取得
    let kClientID = "66855f8a-60cd-445e-a9bb-8cd8eadbd3fa"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kAuthority = "https://login.microsoftonline.com/common"
    let kRedirectUri = "msauth.com.microsoft.identitysample.MSALiOS://auth"

    let kScopes: [String] = ["user.read"]

    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?

    var loggingText: String?

    var currentAccount: MSALAccount?

    //CurrentTeam
    var CurrentTeams = 0
    //JoinedTeams
    var JoinedTeams = [["TeamName":"〇○チーム","Id":20000],["TeamName":"××チーム","Id":30000]]
    
    var YM = YMLoginClient.sharedInstance().storedAuthToken(){
        didSet{
            let TabViewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab")
            performSegue(withIdentifier: "toTab", sender: nil)
        }
    }
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try self.initMSAL()
        } catch let error {
            self.updateLogging(text: "Unable to create Application Context \(error)")
        }
        self.loadCurrentAccount()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        defer{
            let TabViewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab")
            performSegue(withIdentifier: "toTab", sender: nil)
        }
        
        callGraphAPI()
//        YammerTokenが空ならログイン画面表示
//        if YMLoginClient.sharedInstance().storedAuthToken() == nil {
//            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
//            self.present(loginViewController!, animated: true, completion: nil)
//        }
//        callGraphAPI()
//        sleep(10)
    }
    
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
            self.updateLogging(text: "Unable to create authority URL")
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID,
                                                                  redirectUri: kRedirectUri,
                                                                  authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.initWebViewParams()
    }
    
    func initWebViewParams() {
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
    }
    
    func updateLogging(text : String) {
        
        if Thread.isMainThread {
            self.loggingText = text
        } else {
            DispatchQueue.main.async {
                self.loggingText = text
            }
        }
    }
    
    typealias AccountCompletion = (MSALAccount?) -> Void
    
    func loadCurrentAccount(completion: AccountCompletion? = nil) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
                
        // Note that this sample showcases an app that signs in a single account at a time
        // If you're building a more complex app that signs in multiple accounts at the same time, you'll need to use a different account retrieval API that specifies account identifier
        // For example, see "accountsFromDeviceForParameters:completionBlock:" - https://azuread.github.io/microsoft-authentication-library-for-objc/Classes/MSALPublicClientApplication.html#/c:objc(cs)MSALPublicClientApplication(im)accountsFromDeviceForParameters:completionBlock:
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.updateLogging(text: "Couldn't query current account with error: \(error)")
                return
            }
            
            if let currentAccount = currentAccount {
                
                self.updateLogging(text: "Found a signed in account \(String(describing: currentAccount.username)). Updating data for that account...")
                
                self.updateCurrentAccount(account: currentAccount)
                
                if let completion = completion {
                    completion(self.currentAccount)
                }
                
                return
            }
            
            self.updateLogging(text: "Account signed out. Updating UX")
            self.accessToken = ""
            self.updateCurrentAccount(account: nil)
            
            if let completion = completion {
                completion(nil)
            }
        })
    }
    
    func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
    }
    
    func callGraphAPI() {
        
        self.loadCurrentAccount { (account) in
            
            guard let currentAccount = account else {
                
                // We check to see if we have a current logged in account.
                // If we don't, then we need to sign someone in.
                self.acquireTokenInteractively()
                return
            }
            
            self.acquireTokenSilently(currentAccount)
        }
    }
    
    func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            self.updateLogging(text: "Access token is \(self.accessToken)")
            self.updateCurrentAccount(account: result.account)
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        /**
         
         Acquire a token for an existing account silently
         
         - forScopes:           Permissions you want included in the access token received
         in the result in the completionBlock. Not all scopes are
         guaranteed to be included in the access token returned.
         - account:             An account object that we retrieved from the application object before that the
         authentication flow will be locked down to.
         - completionBlock:     The completion block that will be called when the authentication
         flow completes, or encounters an error.
         */
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            self.updateLogging(text: "Refreshed Access token is \(self.accessToken)")
        }
    }
}
