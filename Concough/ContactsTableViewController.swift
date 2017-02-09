//
//  ContactsTableViewController.swift
//  Concough
//
//  Created by Owner on 2017-02-06.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit
import Contacts
import MBProgressHUD

class ContactsTableViewController: UITableViewController, UINavigationControllerDelegate {

    private var loading: MBProgressHUD?
    private var contactStore: CNContactStore!
    private var contacts: [(fullname: String, email: String)] = []
    
    internal var delegate: ContactsProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ارسال", style: .Plain, target: self, action: #selector(self.sendButtonPressed(_:)))
        
        self.tableView.allowsMultipleSelection = true
        self.tableView.tableFooterView = UIView()
        self.contactStore = CNContactStore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        self.requestForAccess()
    }
    
    // MARK: - Actions
    @IBAction func sendButtonPressed(sender: UIBarButtonItem) {
        var localContacts: [(fullname: String, email: String)] = []
        
        if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows {
            for index in selectedIndexPaths {
                localContacts.append(self.contacts[index.row])
            }
        }

        if let d = self.delegate {
            d.contactsSelected(list: localContacts)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Functions
    private func requestForAccess() {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        let authorizedStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizedStatus {
        case .Authorized:
            // load contacts
            self.fetchContacts()
            
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(.Contacts, completionHandler: { (access, accessError) in
                if access == true {
                    // load contacts
                    self.fetchContacts()
                    
                } else {
                    if authorizedStatus == CNAuthorizationStatus.Denied {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                            AlertClass.showAlertMessage(viewController: self, messageType: "Contacts", messageSubType: "Denied", type: "error", completion: {
                                
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                        })
                    }
                }
            })
            
        default:
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    private func fetchContacts() {
        let keys = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactEmailAddressesKey]
        
        var allContainers = [CNContainer]()
        var localContacts = [CNContact]()
        
        do {
            allContainers = try self.contactStore.containersMatchingPredicate(nil)
            
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
                
                do {
                    let containerResult = try self.contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keys)
                    
                    localContacts.appendContentsOf(containerResult)
                } catch {
                    continue
                }
            }
            
            for contact in localContacts {
                if contact.emailAddresses.count > 0 {
                    let fullname = CNContactFormatter.stringFromContact(contact, style: .FullName)
                    for emailAddress in contact.emailAddresses {
                        let email = emailAddress.value as! String
                        
                        self.contacts.append((fullname: fullname!, email: email))
                    }
                }
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
        } catch {
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.showTopMessage(viewController: self, messageType: "Contacts", messageSubType: "FetchError", type: "", completion: nil)
            })
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let item = self.contacts[indexPath.row]
        
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        
        cell.selectionStyle = .None
        cell.accessoryType = rowIsSelected ? .Checkmark : .None
        
        cell.textLabel?.text = item.fullname
        cell.textLabel?.font = UIFont(name: "IRANYekanMobile", size: 14)!
        
        cell.detailTextLabel?.text = item.email
        cell.detailTextLabel?.textColor = UIColor.darkGrayColor()

        cell.imageView?.layer.cornerRadius = 22.0
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.borderColor = UIColor(netHex: 0xEEEEEE, alpha: 1.0).CGColor
        cell.imageView?.layer.borderWidth = 1.0
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .None
    }
    
}
