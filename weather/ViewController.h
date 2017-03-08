//
//  ViewController.h
//  weather
//
//  Created by david on 9/12/15.
//  Copyright (c) 2015 leathal soap, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface ViewController : UIViewController <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation*        currentLocation;       //the current location of the phone
@property (strong, nonatomic) NSDictionary*      weatherDictionary;     //the latest weather information retrieved from openweathermap
@property (strong, nonatomic) NSDate*             previousUpdate;       //the time of the previous weather update

@property (strong) IBOutlet UITableView* weatherTable;
@property (strong) IBOutlet UILabel*     cityLabel;
@property (strong) IBOutlet UILabel*     temperatureLabel;
@property (strong) IBOutlet UILabel*     weatherDescriptionLabel;

-(void)saveData;
-(void)loadData;
-(void)setCurrentCityText;
-(void)setCurrentTemperature;
-(void)setCurrentWeatherDescription;
-(BOOL)isRainInForecast;
-(void)getCurrentLocation;
-(void)getWeatherAtCurrentLocation;

@end

