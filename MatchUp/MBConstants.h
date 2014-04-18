//
//  MBConstants.h
//  MatchUp
//
//  Created by Illinois Business on 4/2/14.
//  Copyright (c) 2014 McCay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBConstants : NSObject

#pragma mark - User Class

extern NSString *const kMBUserProfileKey;
extern NSString *const kMBUserProfileNameKey;
extern NSString *const kMBUserProfileFirstNameKey;
extern NSString *const kMBUserProfileLocation;
extern NSString *const kMBUserProfileGender;
extern NSString *const kMBUserProfileBirthday;
extern NSString *const kMBUserProfileInterestedIn;
extern NSString *const kMBUserProfilePictureURL;
extern NSString *const kMBUserProfileRelationshipStatusKey;
extern NSString *const kMBUserProfileAgeKey;

extern NSString *const kMBUserTagLineKey;

#pragma mark - Photo Class

extern NSString *const kMBPhotoClassKey;
extern NSString *const kMBPhotoUserKey;
extern NSString *const kMBPhotoPictureKey;

#pragma mark - Activity Class

extern NSString *const kMBActivityClassKey;
extern NSString *const kMBActivityTypeKey;
extern NSString *const kMBActivityFromUserKey;
extern NSString *const kMBActivityToUserKey;
extern NSString *const kMBActivityPhotoKey;
extern NSString *const kMBActivityTypeLikeKey;
extern NSString *const kMBActivityTypeDislikeKey;

#pragma mark - Settings

extern NSString *const KMBMenEnabledKey;
extern NSString *const KMBWomenEnabledKey;
extern NSString *const KMBSingleEnabledKey;
extern NSString *const KMBAgeMaxKey;



@end
