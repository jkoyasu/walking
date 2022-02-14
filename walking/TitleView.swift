//
//  TitleView.swift
//  walking
//
//  Created by koyasu on 2022/02/04.
//

import UIKit
import MSAL
import YammerSDK
import HealthKit

class TitleView: UIViewController {
    //全情報取得
    let kClientID = "2ce72229-93e5-4624-99e8-5a490cbe40f9"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kAuthority = "https://login.microsoftonline.com/4c321fca-b3bc-4df6-b1da-a7c90c3dc546/oauth2/v2.0/authorize?"
    let kRedirectUri =  "msauth.com.walkingEventApp://auth"

    let kScopes: [String] = ["user.read"]
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    var loggingText: String?
    var currentAccount: MSALAccount?

    //CurrentTeam
    var CurrentTeams = 0
    //JoinedTeams
    static var team:Team?
    
    var YM = YMLoginClient.sharedInstance().storedAuthToken()
        
    //画面取得後
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try self.initMSAL()
        } catch let error {
            self.updateLogging(text: "Unable to create Application Context \(error)")
        }
        self.loadCurrentAccount()
        
    }
    
    //画面表示後
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//      Yammerのアクセス情報を取得
        let readDataTypes = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!)
        HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes) { success, _ in
            if success {
                if let currentAccount = self.currentAccount{
                    
//        YammerTokenが空ならログイン画面表示
//                    if YMLoginClient.sharedInstance().storedAuthToken() == nil {
//                        DispatchQueue.main.async {
//                            self.performSegue(withIdentifier: "toStart", sender: nil)
                        }
//                    }
                    
                    self.callGraphAPI()
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                        self.performSegue(withIdentifier: "toTab", sender: nil)
//                    }
                }else{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toMSAL", sender: nil)
                    }
                }
            }
        }
    }
    
    func finishCallGraphAPI(result: Bool) {
        //tabのHomeViewにteamが必要ですから、ここに判断を追加
        if (result) {
            self.performSegue(withIdentifier: "toTab", sender: nil)
        }
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
        print(text)
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
            ApplicationData.shared.accessToken = ""
            self.updateCurrentAccount(account: nil)
            
            if let completion = completion {
                completion(nil)
            }
        })
    }
    
    func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
    }
    
    //APIを取得
    func callGraphAPI() {
        
        self.loadCurrentAccount { (account) in
            
            guard let currentAccount = account else {
                
                // We check to see if we have a current logged in account.
                // If we don't, then we need to sign someone in.
                self.acquireTokenInteractively(){ success in
                    self.finishCallGraphAPI(result:success)
                }
                return
            }
            
            self.acquireTokenSilently(currentAccount){ success in
                self.finishCallGraphAPI(result: success)
            }
        }
    }
    
    //ログイントークンを対話的に取得
    func acquireTokenInteractively(completion: @escaping (Bool)->Void) {

        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        var requestError: NSError? = nil
        let request = MSALClaimsRequest(jsonString: "{\"id_token\":{\"auth_time\":{\"essential\":true},\"acr\":{\"values\":[\"urn:mace:incommon:iap:silver\"]}}}",error: &requestError)
        
        parameters.claimsRequest = request
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            ApplicationData.shared.accessToken = result.accessToken
            ApplicationData.shared.idToken = result.idToken!
            self.updateLogging(text: "Access token is \(ApplicationData.shared.accessToken)")
            self.updateCurrentAccount(account: result.account)
            self.getmyInfo(){ result in
                completion(result)
                return
            }
        }
    }
    
    //ログイントークンを暗黙的に取得
    func acquireTokenSilently(_ account : MSALAccount!, completion : @escaping (Bool)->Void) {
        
        guard let applicationContext = self.applicationContext else {
            completion(false)
            return
        }
        
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
        
        var requestError: NSError? = nil
        let request = MSALClaimsRequest(jsonString: "{\"id_token\":{\"auth_time\":{\"essential\":true},\"acr\":{\"values\":[\"urn:mace:incommon:iap:silver\"]}}}",error: &requestError)
        
        parameters.claimsRequest = request
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively(){ result in
                                completion(result)
                            }
                        }
                        return
                    }
                }
                
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                completion(false)
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                completion(false)
                return
            }
            
            ApplicationData.shared.idToken = result.idToken!
            ApplicationData.shared.accessToken = result.accessToken
            self.updateLogging(text: "Refreshed Id token is \(ApplicationData.shared.accessToken)")
            self.getmyInfo(){ result in
                completion(true)
                return
            }
        }
    }
    
    //AAD上の自分の情報取得
    func getmyInfo(completion:@escaping(Bool)->Void){
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/")
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        print("----",ApplicationData.shared.accessToken)
        request.setValue("Bearer \(ApplicationData.shared.accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.updateLogging(text: "Couldn't get graph result: \(error)")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any] else {
                self.updateLogging(text:"Couldn't deserialize result JSON")
                return
            }

            self.updateLogging(text: "Result from Graph: \(result))")
            let MailId = result["userPrincipalName"] as! String
            ApplicationData.shared.mailId = MailId
            ApplicationData.shared.authorizeAWS(id:ApplicationData.shared.mailId) { team in
                ApplicationData.shared.loadMyRanking(id: ApplicationData.shared.mailId) { result in
                    completion(result)
                    return
                }
            }
        }.resume()
    }
}
