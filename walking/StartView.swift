//
//  StartView.swift
//  walking
//
//  Created by koyasu on 2022/01/06.
//

import UIKit
import MSAL
import YammerSDK

var accessToken = String()
var idToken = String()
var mailId = String()

class StartView: UIViewController {
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
    
    var YM = YMLoginClient.sharedInstance().storedAuthToken(){
        didSet{
            let TabViewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab")
            performSegue(withIdentifier: "toTab", sender: nil)
        }
    }
        
    
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
        callGraphAPI()
//        YammerTokenが空ならログイン画面表示
        if YMLoginClient.sharedInstance().storedAuthToken() == nil {
//            YMLoginClient.sharedInstance().startLogin(withContextViewController: self)
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            performSegue(withIdentifier: "toStart", sender: nil)
        }
        
//        取得後、TabViewControllerに移動
        defer{
            let TabViewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab")
            performSegue(withIdentifier: "toTab", sender: nil)
        }
        
        
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
            accessToken = ""
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
                self.acquireTokenInteractively()
                return
            }
            
            self.acquireTokenSilently(currentAccount)
        }
    }
    
    //ログイントークンを対話的に取得
    func acquireTokenInteractively() {
        
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
            
            accessToken = result.accessToken
            idToken = result.idToken!
            self.updateLogging(text: "Access token is \(accessToken)")
            self.updateCurrentAccount(account: result.account)
            self.getmyInfo()
        }
    }
    
    //ログイントークンを暗黙的に取得
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
            
            idToken = result.idToken!
            accessToken = result.accessToken
            self.updateLogging(text: "Refreshed Id token is \(accessToken)")
            self.getmyInfo()
        }
    }
    
    func getmyInfo(){
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/")
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        print("----",accessToken)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
            mailId = MailId
            self.authorizeAWS(id:MailId)
            self.loadMyRanking(id: MailId)
        }.resume()
    }
    
    func loadMyRanking(id:String){
        let data = ["aadid":id]
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(data)
        
        AWSAPI.upload(message: encoded, url: "https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_personal_ranking_api", token: idToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
                    let str = try JSONSerialization.jsonObject(with: result, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
//                    StartView.team = try decoder.decode(Team.self, from: result)
                    print("myInfo",str)
                }catch{
                    print("myInfo",error)
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func authorizeAWS(id:String){
        let data = ["aadid":id]
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(data)
        
        AWSAPI.upload(message: encoded, url: "https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_team_api", token: idToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
//                    let str = try JSONSerialization.jsonObject(with: result, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                    StartView.team = try decoder.decode(Team.self, from: result)
                    print("teamInfo",StartView.team)
                }catch{
                    print("teamInfo",error)
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
}
