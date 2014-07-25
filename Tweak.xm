#import "Headers.h"

#define kWeatherBadgePrefs @"/private/var/mobile/Library/Preferences/com.fortysixandtwo.weatherbadge.plist"

BOOL isEnabled = YES;

static void setWeatherBadge(id value)
{
    SBIcon *icon = (SBIcon *)[[[%c(SBIconViewMap) homescreenMap] iconModel] applicationIconForDisplayIdentifier:@"com.apple.weather"];
    
    if(icon)
    {
        [icon setBadge:value];
    }
}

static void updateWeatherForCurrentLocation(void)
{
    WeatherPreferences *_weatherPreferences = [%c(WeatherPreferences) sharedPreferences];
    WeatherLocationManager *_weatherLocationManager = [%c(WeatherLocationManager) sharedWeatherLocationManager];

    City *_localWeatherCity = [_weatherPreferences localWeatherCity];

    if([[NSDate date] compare:[[_localWeatherCity updateTime] dateByAddingTimeInterval:1800]] == NSOrderedDescending)
    {
        NSLog(@"WeatherBadge: Requesting updated weather.");
        
        [_weatherLocationManager setDelegate:[[%c(CLLocationManager) alloc] init]];
        
        if(![_weatherLocationManager locationTrackingIsReady])
        {
            [_weatherLocationManager setLocationTrackingReady:YES activelyTracking:NO];
        }
        
        [_weatherLocationManager setLocationTrackingActive:YES];
        [_weatherPreferences setLocalWeatherEnabled:YES];
        
        LocationUpdater *_locationUpdater = [%c(LocationUpdater) sharedLocationUpdater];
        [_locationUpdater updateWeatherForLocation:[_weatherLocationManager location] city:_localWeatherCity];
        [_locationUpdater handleCompletionForCity:_localWeatherCity withUpdateDetail:0];
    }
    else
    {
        NSLog(@"WeatherBadge: Request to update too soon. Using cached details.");
        
        BOOL isCelsius = [_weatherPreferences isCelsius];
        BOOL isDataCelsius = [_localWeatherCity isDataCelsius];
        
        CGFloat temperature = [[_localWeatherCity temperature] floatValue];
        
        if(isDataCelsius && !isCelsius)
        {
            temperature = temperature *  9 / 5 + 32;
        }
        else if(!isDataCelsius && isCelsius)
        {
            temperature = temperature - 32 * 5 / 9;
        }
        
        temperature = lroundf(temperature);
        
        setWeatherBadge([NSNumber numberWithInt:temperature]);
    }
}

%hook LocationUpdater
- (void)handleCompletionForCity:(id)city withUpdateDetail:(unsigned long long)detail
{
    %orig;
    
    if(isEnabled)
    {
        BOOL isCelsius = [[%c(WeatherPreferences) sharedPreferences] isCelsius];
        BOOL isDataCelsius = [city isDataCelsius];
        
        CGFloat temperature = [[city temperature] floatValue];
        
        if(isDataCelsius && !isCelsius)
        {
            temperature = temperature *  9 / 5 + 32;
        }
        else if(!isDataCelsius && isCelsius)
        {
            temperature = temperature - 32 * 5 / 9;
        }
        
        temperature = lroundf(temperature);
        
        NSLog(@"WeatherBadge: Update complete.");
        setWeatherBadge([NSNumber numberWithInt:temperature]);
    }
}

- (void)handleNilCity
{
    %orig;
    
    if(isEnabled)
    {
        setWeatherBadge(nil);
    }
}
%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application
{
    %orig;
    
    if(isEnabled)
    {
        updateWeatherForCurrentLocation();
    }
}
%end

%hook SBLockScreenPluginController
- (void)handleUIUnlock
{
    %orig;
    
    if(isEnabled)
    {
        updateWeatherForCurrentLocation();
    }
}
%end

static void loadSettings(void)
{
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:kWeatherBadgePrefs];
    if([prefs objectForKey:@"isEnabled"]) isEnabled = [[prefs objectForKey:@"isEnabled"] boolValue];
    NSLog(@"WeatherBadge: Settings loaded.");
    
    [prefs release];
}

static void reloadPrefsNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    loadSettings();
    
    if(!isEnabled)
    {
        setWeatherBadge(nil);
    }
    else
    {
        updateWeatherForCurrentLocation();
    }
}

%ctor
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    %init;
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&reloadPrefsNotification, CFSTR("com.fortysixandtwo.weatherbadge/settingschanged"), NULL, 0);
    
    loadSettings();
    [pool drain];
}