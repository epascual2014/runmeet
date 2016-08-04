//
//  ActiveGroupViewController.swift
//  Letsrun
//
//  Created by Edrick Pascual on 7/12/16.
//  Copyright © 2016 Edge Designs. All rights reserved.
//

import UIKit
import Firebase

class ActiveGroupViewController: UIViewController {
    
    let firebaseHelper = FirebaseHelper()
    
    var currentGroup = Group?()
    
    //Checking whether current user is a group member.
    var groupMember = [String:Bool]() {
        didSet {
            let thisUser = groupMember.contains { $0.0 == FIRAuth.auth()?.currentUser?.uid }
            if thisUser {
                trueUser = true
            }
        }
    }
    
    var ref: FIRDatabaseReference!
    //var groupsRef: FIRDatabaseReference!
    var trueUser = false
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupDescription: UITextView!

    // Button label and action
   
    @IBOutlet weak var joinGroupButton: UIButton!
    
    @IBAction func joinOrUnjoinTapped(sender: UIButton) {
        if joinGroupButton.titleLabel?.text == "LEAVE GROUP" {
            joinGroupButton.setTitle("JOIN GROUP", forState: .Normal)
            leaveGroup()
        } else {
            joinGroupButton.setTitle("LEAVE GROUP", forState: .Normal)
            joinGroup()
        }
    }
    
    //MARK: Join Group
    func joinGroup() {
        // get the group info on the
        guard let groupID = currentGroup?.groupID, userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let groupRef = ref.child("groups/\(groupID)/groupMembers/\(userID)")
        groupRef.setValue(true)
        print(#function, groupRef)
    }
    
    //MARK: Leave group
    func leaveGroup() {
        guard let groupID = currentGroup?.groupID, userID = FIRAuth.auth()?.currentUser?.uid else { return }
        let groupRef = ref.child("groups/\(groupID)/groupMembers/\(userID)")
        groupRef.removeValue()
        
    }
    
    //MARK: Fetch group data
    func fetchGroups(completion: ((thisGroup: Group) -> Void)?) {
            let groupRef = ref.child("groups")
        
        groupRef.observeSingleEventOfType(.Value) { (groupSnapshot: FIRDataSnapshot) in
                if groupSnapshot.exists() {
                    for groupSnap in groupSnapshot.children {
                        let group = Group(groupSnapshot: (groupSnap as! FIRDataSnapshot))
                        
                        let thisGroup = group
                        print(#function, thisGroup)
                        completion?(thisGroup: group)
                    }
                }
                
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        ref = FIRDatabase.database().reference()
        fetchGroups { (thisGroup: Group) -> Void in
            thisGroup
            
            self.groupMember = thisGroup.groupMembers!
            let isMember = self.groupMember.contains {$0.0 == FIRAuth.auth()?.currentUser?.uid}
            if isMember {
                // Set leave group button
                dispatch_async(dispatch_get_main_queue(), { 
                    self.joinGroupButton.setTitle("LEAVE GROUP", forState: .Normal)
//                    print(#function, self.groupMember, self.thisUser.contains {$0.0 == FIRAuth.auth()?.currentUser?.uid})
                })
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let thisGroup = currentGroup {
            groupNameLabel.text = thisGroup.groupName
            groupDescription.text = thisGroup.groupDescription
        }
        if let groupImageUrl = currentGroup?.groupImageUrl {
            groupImageView.loadImageUsingCacheWithUrlString(groupImageUrl)
        }
    }
    
}

//MARK: UITableViewDataSource
extension ActiveGroupViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("displayFriends", forIndexPath: indexPath) as! ActiveGroupTableViewCell
        return cell
    }
}

















