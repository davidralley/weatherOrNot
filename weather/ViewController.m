//
//  ViewController.m
//  weather
//
//  Created by david on 9/12/15.
//  Copyright (c) 2015 leathal soap, inc. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

//----------------------------------------------------------------------------------
//  viewDidLoad
//----------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //register to be able to deliver notifications, in case it's going to rain
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    [self loadData];    //load the data stored from the last run
    
    //register for notification when the app is terminated, so we can save our current data
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(saveData)
     name: UIApplicationWillTerminateNotification
     object: nil];
    
    //add a refresh control to our table view to allow it to refresh when pulled
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.weatherTable addSubview:refreshControl];
    
    //set our previous update to be a long time ago.
    self.previousUpdate = [NSDate distantPast];
    
    [self getCurrentLocation];
    
}

//----------------------------------------------------------------------------------
//  didReceiveMemoryWarning
//----------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//----------------------------------------------------------------------------------
//  saveData
//----------------------------------------------------------------------------------
// called when the viewController receives a UIApplicationWillTerminateNotification notification
//  this saves the weather dictionary for retrieval on launch
-(void)saveData{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savePath = [documentsDirectory stringByAppendingPathComponent:@"weather.dat"];
    
    [self.weatherDictionary writeToFile: savePath atomically: YES];
}

//----------------------------------------------------------------------------------
//  loadData
//----------------------------------------------------------------------------------
// load the cached weather dictionary data on launch, and redraw the table with this data while waiting
//  on data from openweathermap
-(void)loadData{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *loadPath = [documentsDirectory stringByAppendingPathComponent:@"weather.dat"];
    
     @try {
         self.weatherDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:loadPath];
     } @catch (NSException* exception) {
         // There won't be any cached data on the first run, so we expect to be here initially
         // Surpress any unarchiving exceptions and continue with nil
         NSLog(@"Weather table from cache was failed with exception: %@", [exception reason]);
     }
    
    //load the table with that data
    [self.weatherTable reloadData];
}

//----------------------------------------------------------------------------------
//  refresh
//----------------------------------------------------------------------------------
//callback to refresh the weatherTable when it's pulled.
- (void)refresh:(UIRefreshControl *)refreshControl {
    
    [self getWeatherAtCurrentLocation];
    
    // Do your job, when done:
    [refreshControl endRefreshing];
}


//----------------------------------------------------------------------------------
//  getWeatherAtCurrentLocation
//----------------------------------------------------------------------------------
//use the current location to fetch 16 days worth of weather from http://openweathermap.org/forecast16
-(void)getWeatherAtCurrentLocation{
    
    //build the URL using the information held by the location variable
    NSString* theURL = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=16&units=imperial",
                        self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
   
    //build the request to openweathermap
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString: theURL]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    //note that the code below is depricated, and can be replaced by an async call that uses a completion handler.
    //the same thing can be done using Grand Central Dispatch
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     NSDictionary *stats = [myDoc analyze];
     dispatch_async(dispatch_get_main_queue(), ^{
     [myModel setDict:stats];
     [myStatsView setNeedsDisplay:YES];
     });
     });
     */
    // make the connection to get the received data.
    NSURLResponse *response;
    NSData* theReceivedData = [NSURLConnection sendSynchronousRequest:theRequest
                                             returningResponse:&response error:nil];
    
    //serialize the NSData into an NSDictionary
    self.weatherDictionary = [NSJSONSerialization JSONObjectWithData:theReceivedData options:(NSJSONReadingMutableLeaves + NSJSONReadingMutableContainers) error:nil];
    //NSLog(@"dictionary data %@",self.weatherDictionary);

    [self setCurrentCityText];          //make sure the city text is up-to-date
    [self setCurrentTemperature];       //update the current temperature
    [self setCurrentWeatherDescription];    //update the short description of the current weather
    [self notifyIfRainInForecast];          //show notification if rain is expected in the next 48 hours
    
    //tell the table in the UI to refresh with the new data
    [self.weatherTable reloadData];
}

//----------------------------------------------------------------------------------
//  setCurrentCityText
//----------------------------------------------------------------------------------
// set the current city label in the interface
-(void)setCurrentCityText{
    
    NSDictionary* theCityDict = self.weatherDictionary[@"city"];
    NSString* theCityName = theCityDict[@"name"];
    self.cityLabel.text = theCityName;
}

//----------------------------------------------------------------------------------
//  setCurrentTemperature
//----------------------------------------------------------------------------------
// set the current temperature lablel
-(void)setCurrentTemperature{

    NSArray*    theForecastArray = self.weatherDictionary[@"list"];
    NSDictionary* theDailyForecast = theForecastArray[0];
    NSDictionary* theTemperatures = theDailyForecast[@"temp"];
    double theCurrentTemp = ceil([theTemperatures[@"day"] doubleValue]);
    
    self.temperatureLabel.text = [NSString stringWithFormat:@"%.0f", theCurrentTemp];
}

//----------------------------------------------------------------------------------
//  setCurrentWeatherDescription
//----------------------------------------------------------------------------------
// set the current weather description lablel
-(void)setCurrentWeatherDescription{
    
    NSArray*    theForecastArray = self.weatherDictionary[@"list"];
    NSDictionary* theDailyForecast = theForecastArray[0];
    NSArray* theWeatherInfo = theDailyForecast[@"weather"];
    NSDictionary* theWeatherInfoDict= theWeatherInfo[0];
    NSString* todaysWeatherDecription = theWeatherInfoDict[@"description"];
    
    //get the current short weather description
    self.weatherDescriptionLabel.text = todaysWeatherDecription;
}

//----------------------------------------------------------------------------------
//  notifyIfRainInForecast
//----------------------------------------------------------------------------------
// show a notification if there's rain expected in the next 48 hours
-(BOOL)isRainInForecast{
    
    NSArray*    theForecastArray = self.weatherDictionary[@"list"];
    NSDictionary* theDailyForecast = theForecastArray[0];
    
    NSArray* theWeatherInfo = theDailyForecast[@"weather"];
    NSDictionary* theWeatherInfoDict= theWeatherInfo[0];
    NSString* theWeatherDecription = theWeatherInfoDict[@"description"];
    BOOL rainToday = [theWeatherDecription containsString:@"rain"];
    
    theDailyForecast = theForecastArray[1];
    theWeatherInfo = theDailyForecast[@"weather"];
    theWeatherInfoDict= theWeatherInfo[0];
    theWeatherDecription = theWeatherInfoDict[@"description"];
    BOOL rainTomorrow = [theWeatherDecription containsString:@"rain"];
    
    if (rainToday || rainTomorrow)
        return true;
    else
        return false;
}

//----------------------------------------------------------------------------------
//  notifyIfRainInForecast
//----------------------------------------------------------------------------------
// show a notification if there's rain expected in the next 48 hours
-(void)notifyIfRainInForecast{
    
    if ([self isRainInForecast]){
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];      //1 second from now
        localNotification.alertBody = @"Rain on the way!";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }

}

#pragma mark location routines

//----------------------------------------------------------------------------------
//  getCurrentLocation
//----------------------------------------------------------------------------------
// get the current location data for the phone, and store it in locationManager ivar
-(void)getCurrentLocation{
    //create and start up the location manager
    if([CLLocationManager locationServicesEnabled])
    {
        if(!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        }
        
        CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
        if (authStatus == kCLAuthorizationStatusNotDetermined) {
            // Check for iOS 8 method
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            else {
                [self.locationManager startUpdatingLocation];
            }
        }
        else if(authStatus == kCLAuthorizationStatusAuthorizedAlways ||
                authStatus == kCLAuthorizationStatusAuthorizedWhenInUse ||
                authStatus == kCLAuthorizationStatusAuthorizedAlways) {
            [self.locationManager startUpdatingLocation];
        }
        else if(authStatus == kCLAuthorizationStatusDenied){
            NSLog(@"User did not allow location tracking.");
            // present some dialog that you want the location.
        }
        else {
            // kCLAuthorizationStatusRestricted
            // restriction on the device do not allow location tracking.
        }
    }
    
}

//----------------------------------------------------------------------------------
//  locationManager:didChangeAuthorizationStatus
//----------------------------------------------------------------------------------
//callback from the location manager after user grants location data access
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusRestricted &&  status !=kCLAuthorizationStatusDenied) {
        [self.locationManager startUpdatingLocation];
    }
}

//----------------------------------------------------------------------------------
//  locationManager didFailWithError
//----------------------------------------------------------------------------------
//CLLocationManager delegate function in case of failure to get location information
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);

    
    UIAlertController * errorAlert =   [UIAlertController
                                  alertControllerWithTitle:@"Error"
                                  message:@"Failed to Get Your Location"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [errorAlert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [errorAlert addAction:ok];
    [self presentViewController:errorAlert animated:YES completion:nil];
    
}

//----------------------------------------------------------------------------------
//  didUpdateLocations
//----------------------------------------------------------------------------------
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    self.currentLocation = [locations lastObject];
    NSDate* eventDate = self.currentLocation.timestamp;
    
    //this the checks for weather to one every 30 minutes by caching the previous update, and checking against it.
    NSTimeInterval howRecent = [eventDate timeIntervalSinceDate:self.previousUpdate];
    NSTimeInterval thirtyMinutes = 30*60;   //30 minutes * 60 seconds/minute
    if (fabs(howRecent) > thirtyMinutes) {
        
        [self getWeatherAtCurrentLocation];
        self.previousUpdate = eventDate;
    }
    
    
}

#pragma mark table data routines

//—————————————————————————————————————————————————————————————————————————————————————————————
//                  numberOfRowsInSection
//—————————————————————————————————————————————————————————————————————————————————————————————
// tableview delegate function that provides the number of rows in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int theRowCount = [self.weatherDictionary[@"cnt"] intValue];
    return theRowCount;
}


//—————————————————————————————————————————————————————————————————————————————————————————————
//                  cellForRowAtIndexPath
//—————————————————————————————————————————————————————————————————————————————————————————————
//  provide the content for the specified table cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"dailyForecast";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray*    theForecastArray = self.weatherDictionary[@"list"];
    NSDictionary* theDailyForecast = theForecastArray[indexPath.row];
    
    //get the day of the week as a string
    NSTimeInterval theUNIXDate = [theDailyForecast[@"dt"] doubleValue];
    NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:theUNIXDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"EEEE"];
    NSString* theDayOfTheWeek = [formatter stringFromDate:theDate];
    
    UILabel *theDayLabel = (UILabel *)[cell viewWithTag:200];
    theDayLabel.text = theDayOfTheWeek;
    
    //get the high and low temperatures
    NSDictionary* theTemperatureDict = theDailyForecast[@"temp"];
    double theHighTemp = ceil([theTemperatureDict[@"max"] doubleValue]);
    double theLowTemp = ceil([theTemperatureDict[@"min"] doubleValue]);
    
    UILabel *theHighLabel = (UILabel *)[cell viewWithTag:300];
    theHighLabel.text = [NSString stringWithFormat:@"%.0f", theHighTemp];
    
    UILabel *theLowLabel = (UILabel *)[cell viewWithTag:400];
    theLowLabel.text = [NSString stringWithFormat:@"%.0f", theLowTemp];
    
    return cell;
}

@end
