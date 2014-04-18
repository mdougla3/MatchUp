//
//  MBHomeViewController.m
//  MatchUp
//
//  Created by Illinois Business on 4/3/14.
//  Copyright (c) 2014 McCay. All rights reserved.
//

#import "MBHomeViewController.h"
#import "MBTestUser.h"
#import "MBProfileViewController.h"
#import "MBMatchViewController.h"

@interface MBHomeViewController () <MBMatchViewContollerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;


@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;


@end

@implementation MBHomeViewController

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
    
    //[MBTestUser saveTestUserToParse];
    
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kMBPhotoClassKey];
    [query whereKey:kMBPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kMBPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            [self queryForCurrentPhotoIndex];
        }
        else { NSLog(@"Error");}
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"]) {
        MBProfileViewController *profileVC = segue.destinationViewController;
        profileVC.photo = self.photo;
    }
    else if ([segue.identifier isEqualToString:@"homeToMatchSegue"])
    {
        MBMatchViewController *matchVC = segue.destinationViewController;
        matchVC.matchedUserImage = self.photoImageView.image;
        matchVC.delegate = self;
    }
}


#pragma mark - IBActions

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender
{
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender
{
}

- (IBAction)likeButtonPressed:(UIButton *)sender
{
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender
{
    [self checkdisLike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}



#pragma mark - Helper Method

-(void)queryForCurrentPhotoIndex
{
    if ([self.photos count] > 0)
    {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kMBPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
            UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
            [self updateView];
            }
            else NSLog(@"%@", error);
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:kMBActivityClassKey];
        [queryForLike whereKey:kMBActivityTypeKey equalTo:kMBActivityTypeLikeKey];
        [queryForLike whereKey:kMBActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kMBActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kMBActivityClassKey];
        [queryForDislike whereKey:kMBActivityTypeKey equalTo:kMBActivityTypeDislikeKey];
        [queryForDislike whereKey:kMBActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:kMBActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.activities = [objects mutableCopy];
                
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                }
                else {
                    PFObject *activity = self.activities[0];
                    
                    if ([activity [kMBActivityTypeKey] isEqualToString:kMBActivityTypeLikeKey]) {
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }
                    else if ([activity[kMBActivityTypeKey] isEqualToString:kMBActivityTypeDislikeKey]){
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    }
                    self.likeButton.enabled = YES;
                    self.dislikeButton.enabled = YES;
                    self.infoButton.enabled = YES;
                }
            }
        }];
        
        
    }
}


-(void)updateView
{
    self.firstNameLabel.text = self.photo[kMBPhotoUserKey][kMBUserProfileKey][kMBUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kMBPhotoUserKey][kMBUserProfileKey][kMBUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kMBPhotoUserKey][kMBUserTagLineKey];
    
}


-(void)setUpNextPhoto
{
    if (self.currentPhotoIndex + 1 < self.photos.count)
    {
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users to View" message:@"Check back Later for more People!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}


-(void)saveLike
{
    PFObject *likeActivity = [PFObject objectWithClassName:kMBActivityClassKey];
    [likeActivity setObject:kMBActivityTypeLikeKey forKey:kMBActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kMBActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kMBPhotoUserKey] forKey:kMBActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kMBActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self checkForPhotoUserLikes];
        [self setUpNextPhoto];
    }];
}

-(void)saveDislike
{
    PFObject *dislikeActivity = [PFObject objectWithClassName:kMBActivityClassKey];
    [dislikeActivity setObject:kMBActivityTypeDislikeKey forKey:kMBActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kMBActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kMBPhotoUserKey] forKey:kMBActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kMBActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setUpNextPhoto];
    }];
}

-(void)checkLike
{
    if (self.isLikedByCurrentUser) {
        [self setUpNextPhoto];
        return;
    }
    else if (self.isDislikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else  [self saveLike];
}

-(void)checkdisLike
{
    if (self.isDislikedByCurrentUser) {
        [self setUpNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else {
        [self saveDislike];
    }
}

-(void)checkForPhotoUserLikes
{
    PFQuery *query = [PFQuery queryWithClassName:kMBActivityClassKey];
    [query whereKey:kMBActivityFromUserKey equalTo:self.photo[kMBPhotoUserKey]];
    [query whereKey:kMBActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kMBActivityTypeKey equalTo:kMBActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            [self createChatRoom];
        }
    }];
}

-(void)createChatRoom
{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoom whereKey:@"user1" equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:@"user2" equalTo:self.photo[kMBPhotoUserKey]];
    
    PFQuery *queryChatRoomInverse = [PFQuery queryWithClassName:@"Chatroom"];
    [queryChatRoomInverse whereKey:@"user1" equalTo:self.photo[kMBPhotoUserKey]];
    [queryChatRoomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryChatRoomInverse]];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count]  == 0) {
            PFObject *chatroom = [PFObject objectWithClassName:@"ChatRoom"];
            [chatroom setObject:[PFUser currentUser] forKey:@"user1"];
            [chatroom setObject:self.photo[kMBPhotoUserKey] forKey:@"user2"];
            [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
            }];
        }
    }];
}

#pragma mark - MBMatchViewController Delegate

-(void)presentMatchesViewController
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
}






@end
