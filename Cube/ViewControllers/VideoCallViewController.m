//
//  VideoCallViewController.m
//  Cube
//
//  Created by mac on 21/03/20.
//  Copyright © 2020 Xanadutec. All rights reserved.
//

#import "VideoCallViewController.h"

@interface VideoCallViewController ()

@end

@implementation VideoCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"facetime://mahadevmandale@yahoo.com"]];
//
    // Do any additional setup after loading the view.
}

//-(void) getContactPermission
//{
//   CNContactStore *store = [[CNContactStore alloc] init];
//    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        if (granted == YES) {
//            //keys with fetching properties
//            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
//            NSString *containerId = store.defaultContainerIdentifier;
//            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
//            NSError *error;
//            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
//            if (error) {
//                NSLog(@"error fetching contacts %@", error);
//            } else {
//                for (CNContact *contact in cnContacts) {
//                    // copy data to my custom Contacts class.
//                    Contact *newContact = [[Contact alloc] init];
//                    newContact.firstName = contact.givenName;
//                    newContact.lastName = contact.familyName;
//                    UIImage *image = [UIImage imageWithData:contact.imageData];
//                    newContact.image = image;
//                    for (CNLabeledValue *label in contact.phoneNumbers) {
//                        NSString *phone = [label.value stringValue];
//                        if ([phone length] > 0) {
//                            [contact.phones addObject:phone];
//                        }
//                    }
//                }
//            }
//        }
//    }];
//}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
