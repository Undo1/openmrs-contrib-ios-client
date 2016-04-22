//
//  LoginViewController.swift
//  OpenMRS-iOS
//
//  Created by Parker on 4/20/16.
//  Copyright © 2016 Erway Software. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var hostField: UITextField! {
        didSet {
            hostField.addTarget(self, action: #selector(LoginViewController.updateHost(_:)), forControlEvents: .EditingChanged)
        }
    }
    var usernameField: UITextField! {
        didSet {
            usernameField.addTarget(self, action: #selector(LoginViewController.updateUsername(_:)), forControlEvents: .EditingChanged)
        }
    }
    var passwordField: UITextField! {
        didSet {
            passwordField.addTarget(self, action: #selector(LoginViewController.updatePassword(_:)), forControlEvents: .EditingChanged)
        }
    }
    
    var host: String!
    var username: String!
    var password: String!
    
    
    @IBAction func useDemoServer(sender: UIButton) {
        self.hostField.text = "http://demo.openmrs.org/openmrs"
        self.updateHost(self.hostField)
        
        self.usernameField.text = "admin"
        self.updateUsername(self.usernameField)
        
        self.passwordField.text = "Admin123"
        self.updatePassword(self.passwordField)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
        self.hostField.becomeFirstResponder()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return 3
        }
        else
        {
            return 1
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("fieldCell")! as! LoginFieldCell
            
            cell.legendLabel.text = ["Host", "Username", "Password"][indexPath.row]
            cell.textField.placeholder = ["Host", "Username", "Password"][indexPath.row]
            cell.textField.text = [host, username, password][indexPath.row]
            cell.textField.delegate = self
            cell.textField.returnKeyType = .Next
            
            switch indexPath.row {
                case 0:
                    hostField = cell.textField
                case 1:
                    usernameField = cell.textField
                case 2:
                    passwordField = cell.textField
                    cell.textField.secureTextEntry = true
                    cell.textField.returnKeyType = .Go
                default: break
            }
            
            cell.selectionStyle = .None
            
            return cell
        }
        else
        {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.text = "Login"
            cell.textLabel?.textColor = UIColor(red: 39/255, green: 139/255, blue: 146/255, alpha: 1)
            
            return cell
        }
    }
    
    func login()
    {
        if host == nil || host == "" || username == nil || username == "" || password == nil || password == ""
        {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Warning label error"), message: "One or more fields are empty. All are required.", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            self.showViewController(alert, sender: nil)
            
            return
        }
        
        host = addProtocolToHost(host)
        self.hostField.text = host
        
        MBProgressExtension.showBlockWithTitle(NSLocalizedString("Loading", comment: "Label loading"), inView: self.view)
        OpenMRSAPIManager.verifyCredentialsWithUsername(username, password: password, host: host) { (error: NSError!) in
            if error == nil
            {
                MBProgressExtension.showSucessWithTitle(NSLocalizedString("Logged in", comment: "Message -logged- -in-"), inView: self.presentingViewController!.view)
                self.updateKeychainItemWithHost(self.host, username: self.username, password: self.password)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
                }
            }
            else
            {
                if error.code == -1011 // Incorrect credentials
                {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Warning label error"), message: NSLocalizedString("Invalid credentials", comment: "warning label invalid credentials"), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        
                    self.showViewController(alert, sender: nil)
                }
                else
                {
                    MRSAlertHandler.alertViewForError(self, error: error).show()
                }
            }
        }
    }
    
//    - (void)updateKeychainWithHost:(NSString *)host username:(NSString *)username password:(NSString *)password
//    {
//    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"OpenMRS-iOS" accessGroup:nil];
//    [wrapper setObject:password forKey:(__bridge id)(kSecValueData)];
//    [wrapper setObject:username forKey:(__bridge id)(kSecAttrAccount)];
//    [wrapper setObject:host forKey:(__bridge id)(kSecAttrService)];
//    }

    func updateKeychainItemWithHost(host: String, username: String, password: String)
    {
        let wrapper = KeychainItemWrapper.init(identifier: "OpenMRS-iOS", accessGroup: nil)
        wrapper.setObject(host, forKey: kSecAttrService)
        wrapper.setObject(username, forKey: kSecAttrAccount)
        wrapper.setObject(password, forKey: kSecValueData)
    }
    

    func addProtocolToHost(hostString: String) -> String {
        if !hostString.hasPrefix("htt") // Account for both http and https. Not perfect, but it works
        {
            return "http://".stringByAppendingString(hostString)
        }
        
        return hostString
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 38
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1
        {
            login()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func updateUsername(sender: UITextField!)
    {
        username = sender.text
    }
    func updatePassword(sender: UITextField!)
    {
        password = sender.text
    }
    func updateHost(sender: UITextField!)
    {
        host = sender.text
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == hostField
        {
            usernameField.becomeFirstResponder()
        }
        else if textField == usernameField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            login()
        }
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}