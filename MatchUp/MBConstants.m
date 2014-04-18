//
//  MBConstants.m
//  MatchUp
//
//  Created by Illinois Business on 4/2/14.
//  Copyright (c) 2014 McCay. All rights reserved.
//

#import "MBConstants.h"

@implementation MBConstants

#pragma mark - User Class

NSString *const kMBUserProfileKey                   = @"profile";
NSString *const kMBUserProfileNameKey               = @"name";
NSString *const kMBUserProfileFirstNameKey          = @"firstName";
NSString *const kMBUserProfileLocation              = @"location";
NSString *const kMBUserProfileGender                = @"gender";
NSString *const kMBUserProfileBirthday              = @"birthday";
NSString *const kMBUserProfileInterestedIn          = @"interestedIn";
NSString *const kMBUserProfilePictureURL            = @"pictureURL";
NSString *const kMBUserProfileAgeKey                = @"age";
NSString *const kMBUserProfileRelationshipStatusKey = @"relationship_status";

NSString *const kMBUserTagLineKey                   = @"tagLine";


#pragma mark - Photo Class

NSString *const kMBPhotoClassKey                    = @"Photo";
NSString *const kMBPhotoUserKey                     = @"user";
NSString *const kMBPhotoPictureKey                  = @"image";


#pragma mark - Activity Class

NSString *const kMBActivityClassKey                 = @"Activity";
NSString *const kMBActivityTypeKey                  = @"type";
NSString *const kMBActivityFromUserKey              = @"fromUser";
NSString *const kMBActivityToUserKey                = @"toUser";
NSString *const kMBActivityPhotoKey                 = @"photo";
NSString *const kMBActivityTypeLikeKey              = @"like";
NSString *const kMBActivityTypeDislikeKey           = @"dislike";

#pragma mark - Settings


NSString *const KMBMenEnabledKey                    =@"men";
NSString *const KMBWomenEnabledKey                  =@"women";
NSString *const KMBSingleEnabledKey                 =@"single";
NSString *const KMBAgeMaxKey                        =@"ageMax";

@end
