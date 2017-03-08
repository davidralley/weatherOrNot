//
//  WeatherUnitTests.m
//  weather
//
//  Created by david on 9/18/15.
//  Copyright (c) 2015 leathal soap, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"
#import <OCMock/OCMock.h>

@interface WeatherUnitTests : XCTestCase

@property (nonatomic, strong) ViewController* vc;

@end

@implementation WeatherUnitTests



//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  setUp
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  load the view controller from the storyboard
- (void)setUp
{
    [super setUp];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.vc = [storyboard instantiateViewControllerWithIdentifier:@"main"];
    [self.vc performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
}


//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  tearDown
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  release the main view after testing it
- (void)tearDown {
    self.vc = nil;
    [super tearDown];
}


#pragma mark - View loading tests
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testThatViewLoads
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-(void)testThatViewLoads
{
    XCTAssertNotNil(self.vc.view, @"View not initiated properly");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testParentViewHasTableViewSubview
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testParentViewHasTableViewSubview
{
    NSArray *subviews = self.vc.view.subviews;
    XCTAssertTrue([subviews containsObject:self.vc.weatherTable], @"View does not have a table subview");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testParentViewHasCityLabelSubview
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testParentViewHasCityLabelSubview
{
    NSArray *subviews = self.vc.view.subviews;
    XCTAssertTrue([subviews containsObject:self.vc.cityLabel], @"View does not have a cityLabel subview");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testParentViewHasWeatherDescriptionLabelSubview
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testParentViewHasWeatherDescriptionLabelSubview
{
    NSArray *subviews = self.vc.view.subviews;
    XCTAssertTrue([subviews containsObject:self.vc.weatherDescriptionLabel], @"View does not have a WeatherDescription subview");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testParentViewHasTemperatureLabelSubview
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testParentViewHasTemperatureLabelSubview
{
    NSArray *subviews = self.vc.view.subviews;
    XCTAssertTrue([subviews containsObject:self.vc.temperatureLabel], @"View does not have a TemperatureLabel subview");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testThatTableViewLoads
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-(void)testThatTableViewLoads
{
    XCTAssertNotNil(self.vc.weatherTable, @"TableView not initiated");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testThatCityLabelLoads
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-(void)testThatCityLabelLoads
{
    XCTAssertNotNil(self.vc.cityLabel, @"cityLabel not initiated");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testThatTemperatureLabelLoads
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-(void)testThatTemperatureLabelLoads
{
    XCTAssertNotNil(self.vc.cityLabel, @"TemperatureLabel not initiated");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testThatWeatherDescriptionLabelLoads
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-(void)testThatWeatherDescriptionLabelLoads
{
    XCTAssertNotNil(self.vc.cityLabel, @"WeatherDescriptionLabel not initiated");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testSetCurrentCityText
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//make sure the setting of the current city text works as expected
-(void)testSetCurrentCityText{
    
    NSDictionary* theCityDict = [NSDictionary dictionaryWithObjectsAndKeys:@"city name", @"name", nil ];
    NSDictionary* theWeatherDict = [NSDictionary dictionaryWithObjectsAndKeys:theCityDict, @"city", nil ];
    self.vc.weatherDictionary = theWeatherDict;
    
    [self.vc setCurrentCityText];
    
    NSString* theCityLabelText = self.vc.cityLabel.text;
    XCTAssertTrue([theCityLabelText isEqualToString:@"city name"] );
    
}
    
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testSetTemperatureText
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//make sure the setting of the current temperature label works as expected
-(void)testSetTemperatureText{
    
    NSDictionary* theTemperatures = [NSDictionary dictionaryWithObjectsAndKeys:@"100", @"day", nil ];
    NSDictionary *theDailyForecast = [NSDictionary dictionaryWithObjectsAndKeys:theTemperatures, @"temp", nil];
    NSArray* theForecastArray = [NSArray arrayWithObjects:theDailyForecast, nil];
    NSDictionary* theWeatherDict = [NSDictionary dictionaryWithObjectsAndKeys:theForecastArray, @"list", nil];
    self.vc.weatherDictionary = theWeatherDict;
    
    [self.vc setCurrentTemperature];
    
    XCTAssertTrue([self.vc.temperatureLabel.text isEqualToString:@"100"] );
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testSetCWeatherDescriptionText
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//make sure the setting of the current weather description text works as expected
-(void)testSetCWeatherDescriptionText{
    
    NSDictionary* theWeatherInfoDict = [NSDictionary dictionaryWithObjectsAndKeys: @"meatballs", @"description", nil];
    NSArray* theWeatherInfo = [NSArray arrayWithObjects:theWeatherInfoDict, nil];
    NSDictionary* theDailyForecast = [NSDictionary dictionaryWithObjectsAndKeys: theWeatherInfo, @"weather", nil];
    NSArray* theForecastArray = [NSArray arrayWithObjects:theDailyForecast, nil];
    NSDictionary* theWeatherDict = [NSDictionary dictionaryWithObjectsAndKeys:theForecastArray, @"list", nil];
    self.vc.weatherDictionary = theWeatherDict;
    
    [self.vc setCurrentWeatherDescription];
    
    XCTAssertTrue([self.vc.weatherDescriptionLabel.text isEqualToString:@"meatballs"] );
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testRainInForecast
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//make sure that if there's rain in the forecast, it's found
-(void)testIsRainInForecast{
    
    //today's weather
    NSDictionary* theWeatherInfoDict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"rain", @"description", nil];
    NSArray* theWeatherInfo1 = [NSArray arrayWithObjects:theWeatherInfoDict1, nil];
    NSDictionary* theDailyForecast1 = [NSDictionary dictionaryWithObjectsAndKeys: theWeatherInfo1, @"weather", nil];
    
    //tomorrow's weather
    NSDictionary* theWeatherInfoDict2 = [NSDictionary dictionaryWithObjectsAndKeys: @"clear", @"description",nil];
    NSArray* theWeatherInfo2 = [NSArray arrayWithObjects:theWeatherInfoDict2, nil];
    NSDictionary* theDailyForecast2 = [NSDictionary dictionaryWithObjectsAndKeys: theWeatherInfo2, @"weather", nil];
    
    NSArray* theForecastArray = [NSArray arrayWithObjects:theDailyForecast1, theDailyForecast2, nil];
    NSDictionary* theWeatherDict = [NSDictionary dictionaryWithObjectsAndKeys:theForecastArray, @"list", nil];
    self.vc.weatherDictionary = theWeatherDict;
    
    XCTAssertTrue([self.vc isRainInForecast]);
}

#pragma mark - UITableView tests
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testThatViewConformsToUITableViewDataSource
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testThatViewConformsToUITableViewDataSource
{
    XCTAssertTrue([self.vc conformsToProtocol:@protocol(UITableViewDataSource) ], @"View does not conform to UITableView datasource protocol");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testThatTableViewHasDataSource
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testThatTableViewHasDataSource
{
    XCTAssertNotNil(self.vc.weatherTable.dataSource, @"Table datasource cannot be nil");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testThatViewConformsToUITableViewDelegate
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testThatViewConformsToUITableViewDelegate
{
    XCTAssertTrue([self.vc conformsToProtocol:@protocol(UITableViewDelegate) ], @"View does not conform to UITableView delegate protocol");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testTableViewIsConnectedToDelegate
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testTableViewIsConnectedToDelegate
{
    XCTAssertNotNil(self.vc.weatherTable.delegate, @"Table delegate cannot be nil");
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testLocationManagerStarted
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//
//- (void)testLocationManagerStarted
//{
//    id mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
//    [[mockLocationManager expect] locationManager:mockLocationManager
//                               didUpdateLocations:[OCMArg anyPointer]];
//    
//    [mockLocationManager verify];
//    
//    mockLocationManager = nil;
//}



//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testParentViewHasTableViewSubview
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  test the save/load mechanism for weather table data. 
- (void)testLoadSave {
    
    self.vc.weatherDictionary =  @{
      @"key1" : @"value1",
      @"key2" : @"value2"};
    
    //save the weather dictionary
    [self.vc saveData];
    
    [self.vc loadData];
    NSString *savedValue = [self.vc.weatherDictionary objectForKey:@"key1"];
    
    XCTAssertTrue([savedValue isEqualToString:@"value1"] );
}


//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testLocationManagerNotNil
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testLocationManagerNotNil{
    
    [self.vc getCurrentLocation];
    XCTAssertTrue(self.vc.locationManager != nil );
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testThatLocationManagerDelegateNotNil
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
- (void)testThatLocationManagerDelegateNotNil {
    
    [self.vc getCurrentLocation];
    XCTAssertTrue(self.vc.locationManager.delegate != nil );
    
    XCTAssertTrue(self.vc == self.vc.locationManager.delegate);
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//  testLocationManagerCallback
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
//test to make sure the location manager delegate function is called as a result of getting the location
- (void)testLocationManagerCallback
{
    CLLocation* theLocation = [[CLLocation alloc] initWithLatitude:10.0 longitude:20.0];
    NSArray* theArray = [NSArray arrayWithObjects:theLocation, nil];
    
    [self.vc getCurrentLocation];
    [self.vc locationManager:self.vc.locationManager didUpdateLocations:theArray];
    
    CLLocation*  theNewLocation = self.vc.currentLocation;
    
    XCTAssertTrue(theNewLocation.coordinate.latitude == 10.0);
    XCTAssertTrue(theNewLocation.coordinate.longitude == 20.0);
 }


@end
