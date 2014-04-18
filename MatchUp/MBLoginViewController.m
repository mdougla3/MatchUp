//
//  MBLoginViewController.m
//  MatchUp
//
//  Created by Illinois Business on 4/2/14.
//  Copyright (c) 2014 McCay. All rights reserved.
//

#import "MBLoginViewController.h"

@interface MBLoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation MBLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activityIndicator.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

- (IBAction)loginButtonPressed:(UIButton *)sender
{
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests",@"user_relationships",@"user_birthday",@"user_location",@"user_relationship_details"];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        if(!user){
            if(!error){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Login Error" message:@"Login Canceled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Login Error" message:@"Login Canceled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
        }
        else {
//            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
        }
    }];
    
    [self.activityIndicator stopAnimating];
    
}

#pragma mark - Helper Methods

-(void)updateUserInformation
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        //  Print Facebook Data      NSLog(@"%@", result);
        
        if(!error){
            NSDictionary *userDictionary = (NSDictionary *)result;

            // Create URL
            
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            if(userDictionary[@"name"]){
                userProfile[kMBUserProfileNameKey] = userDictionary[@"name"];
            }
            if(userDictionary[@"first_name"]){
                userProfile[kMBUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if(userDictionary[@"location"][@"name"]){
                userProfile[kMBUserProfileLocation] = userDictionary[@"location"][@"name"];
            }
            if(userDictionary[@"gender"]){
                userProfile[kMBUserProfileGender] = userDictionary[@"gender"];
            }
            if(userDictionary[@"birthday"]){
                userProfile[kMBUserProfileBirthday] = userDictionary[@"birthday"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval  seconds = [now timeIntervalSinceDate:date];
                int age = seconds / 31536000;
                userProfile[kMBUserProfileAgeKey] = @(age);
            }
            if(userDictionary[@"interested_in"]){
                userProfile[kMBUserProfileInterestedIn] = userDictionary[@"interested_in"];
            }
            
            if(userDictionary[@"relationship_status"]){
                userProfile[kMBUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[kMBUserProfilePictureURL] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kMBUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
                 
        }
        else {
            NSLog(@"Error in facebook request%@", error);
        }
    }];
    
    
}

-(void)uploadPFFileToParse:(UIImage *)image
{
    NSLog(@"upload called");
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFObject *photo = [PFObject objectWithClassName:kMBPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kMBPhotoUserKey];
            [photo setObject:photoFile forKey:kMBPhotoPictureKey];
            
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved successfully");
            }];
        }
    }];
}

-(void)requestImage
{
    
    PFQuery *query = [PFQuery queryWithClassName:kMBPhotoClassKey];
    [query whereKey:kMBPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(number == 0)
        {
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];
            NSURL *profilePictureURL = [NSURL URLWithString:user[kMBUserProfileKey][kMBUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            
            if(!urlConnection) NSLog(@"Failed to Download Picture");
        }
    }];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}















@end
