//
//  ESTViewController.m
//  DistanceDemo
//
//  Created by Marcin Klimek on 9/26/13.
//  Copyright (c) 2013 Estimote. All rights reserved.
//

#import "ESTViewController.h"
#import <ESTBeaconManager.h>

#define DOT_MIN_POS 120
#define DOT_MAX_POS screenHeight - 70;

@interface ESTViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) UIImageView*      positionDot;
@property (nonatomic, strong) ESTBeacon*        selectedBeacon;

@property (nonatomic) float dotMinPos;
@property (nonatomic) float dotRange;

@end

@implementation ESTViewController

#pragma mark - View Setup

- (void)setupBackgroundImage
{
    CGRect          screenRect          = [[UIScreen mainScreen] bounds];
    CGFloat         screenHeight        = screenRect.size.height;
    UIImageView*    backgroundImage;
    
    if (screenHeight > 480)
    {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundBig"]];
    }
    else
    {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundSmall"]];
    }
    
    [self.view addSubview:backgroundImage];
}

- (void)setupDotImage
{
    self.positionDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dotImage"]];
    [self.positionDot setCenter:self.view.center];
    [self.positionDot setAlpha:1.0f];
    
    [self.view addSubview:self.positionDot];
    
    self.dotMinPos = 150;
    self.dotRange = self.view.bounds.size.height  - 220;
}

- (void)setupView
{
    [self setupBackgroundImage];
    [self setupDotImage];
}

#pragma mark - Manager setup

- (void)setupManager
{
    // create manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                  identifier:@"EstimoteSampleRegion"];
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
}

#pragma mark - ViewController Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupManager];
    [self setupView];
}

#pragma mark - ESTBeaconManagerDelegate Implementation

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        if(!self.selectedBeacon)
        {
            // initially pick closest beacon
            self.selectedBeacon = [beacons objectAtIndex:0];
        }
        else
        {
            for (ESTBeacon* cBeacon in beacons)
            {
                // update beacon it same as selected initially
                if([self.selectedBeacon.major unsignedShortValue] == [cBeacon.major unsignedShortValue] &&
                   [self.selectedBeacon.minor unsignedShortValue] == [cBeacon.minor unsignedShortValue])
                {
                    self.selectedBeacon = cBeacon;
                }
            }
        }
        
        // based on observation rssi is not getting bigger then -30
        // so it changes from -30 to -100 so we normalize
        float distFactor = ((float)self.selectedBeacon.rssi + 30) / -70;
        
        // calculate and set new y position
        float newYPos = self.dotMinPos + distFactor * self.dotRange;
        self.positionDot.center = CGPointMake(self.view.bounds.size.width / 2, newYPos);
    }
}

@end
