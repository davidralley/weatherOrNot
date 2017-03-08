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
//    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    NSError* error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource: @"city.list.us" ofType: @"json"];
    NSString *theCityStrings = [NSString stringWithContentsOfFile: path encoding:NSUTF8StringEncoding error: &error];
    NSData *data = [theCityStrings dataUsingEncoding:NSUTF8StringEncoding];
    self.cityDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    
    
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
//  fetchWeatherForCity
//----------------------------------------------------------------------------------
//use the current location to fetch the weather
-(void)fetchWeatherForCity:(NSString*)inCityID{
    
    NSString* theAppID = @"16b0456f011b3fb9f3dc9840966f9966";
    
    //build the URL using the information held by the location variable
    NSString* theString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&cnt=7&units=imperial&APPID=%@",
                           inCityID, theAppID];
    NSURL*  theURL = [NSURL URLWithString: theString];
    
    //build the request to openweathermap
    NSURLSessionDownloadTask *getWeatherTask = [[NSURLSession sharedSession] downloadTaskWithURL:theURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData* theReceivedData =  [NSData dataWithContentsOfURL:location];
        //serialize the NSData into an NSDictionary
        self.weatherDictionary = [NSJSONSerialization JSONObjectWithData:theReceivedData options:(NSJSONReadingMutableLeaves + NSJSONReadingMutableContainers) error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.weatherTable reloadData];
            [self setCurrentCityText];          //make sure the city text is up-to-date
            [self setCurrentTemperature];       //update the current temperature
            [self setCurrentWeatherDescription];    //update the short description of the current weather
        });
        
        
    }];
    
    [getWeatherTask resume];
    
    
}

//----------------------------------------------------------------------------------
//  getWeatherAtCurrentLocation
//----------------------------------------------------------------------------------
//use the current location to fetch the weather
-(void)getWeatherAtCurrentLocation{
    
    NSString* theAppID = @"16b0456f011b3fb9f3dc9840966f9966";
    
    //build the URL using the information held by the location variable
    NSString* theString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=7&units=imperial&APPID=%@",
                        self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, theAppID];
    NSURL*  theURL = [NSURL URLWithString: theString];
   
    //build the request to openweathermap
    NSURLSessionDownloadTask *getWeatherTask = [[NSURLSession sharedSession] downloadTaskWithURL:theURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData* theReceivedData =  [NSData dataWithContentsOfURL:location];
        //serialize the NSData into an NSDictionary
        self.weatherDictionary = [NSJSONSerialization JSONObjectWithData:theReceivedData options:(NSJSONReadingMutableLeaves + NSJSONReadingMutableContainers) error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.weatherTable reloadData];
            [self setCurrentCityText];              //make sure the city text is up-to-date
            [self setCurrentTemperature];           //update the current temperature
            [self setCurrentWeatherDescription];    //update the short description of the current weather
        });
        
        
    }];
    
    [getWeatherTask resume];
    
    
 }

//----------------------------------------------------------------------------------
//  fetchWeatherIcon
//----------------------------------------------------------------------------------
//use the current location to fetch the weather
-(void)fetchWeatherIcon:(NSString *)inIconString{
    
    
    //build the URL for the correct image
    NSString* theString = [NSString stringWithFormat:@"http://api.openweathermap.org/img/w/%@.png",
                           inIconString];
    NSURL*  theURL = [NSURL URLWithString: theString];
    
    //build the request to openweathermap
    NSURLSessionDownloadTask *getWeatherTask = [[NSURLSession sharedSession] downloadTaskWithURL:theURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        UIImage* theImage =  [UIImage imageWithData: [NSData dataWithContentsOfURL:location]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.weatherIcon setImage:theImage];
        });
        
        
    }];
    
    [getWeatherTask resume];
    
}
//----------------------------------------------------------------------------------
//  setCurrentCityText
//----------------------------------------------------------------------------------
// set the current city label in the interface
-(void)setCurrentCityText{
    
    NSString* theCityName = self.weatherDictionary[@"city"][@"name"];
    self.cityLabel.text = theCityName;
}

//----------------------------------------------------------------------------------
//  setCurrentTemperature
//----------------------------------------------------------------------------------
// set the current temperature lablel
-(void)setCurrentTemperature{

    NSDictionary*    theCurrentConditions = self.weatherDictionary[@"list"][0];
    NSNumber* theTemperature = theCurrentConditions[@"temp"][@"day"];
    
    self.temperatureLabel.text = [NSString stringWithFormat:@"%.0f\u00B0", [theTemperature floatValue]];
}

//----------------------------------------------------------------------------------
//  setCurrentWeatherDescription
//----------------------------------------------------------------------------------
// set the current weather description lablel
-(void)setCurrentWeatherDescription{
    
    NSArray* theWeatherInfo = self.weatherDictionary[@"list"][0][@"weather"];
    NSDictionary* theWeatherInfoDict= theWeatherInfo[0];
    NSString* todaysWeatherDecription = theWeatherInfoDict[@"description"];
    
    //get the current short weather description
    self.weatherDescriptionLabel.text = todaysWeatherDecription;
    
    //get the correct icon for this weather
    NSString* theWeatherIcon = theWeatherInfoDict[@"icon"];
    [self fetchWeatherIcon:theWeatherIcon];
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

#pragma mark- search bar
//—————————————————————————————————————————————————————————————————————————————————————————————
//                  searchBar:searchBarSearchButtonClicked
//—————————————————————————————————————————————————————————————————————————————————————————————
//  the user initiated a search, so look up that location

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString* theNewCity = searchBar.text;
    //[self findCityIDForCity];
    [self fetchWeatherForCity:theNewCity];
}

@end
