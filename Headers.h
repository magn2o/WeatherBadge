@interface City
- (id)temperature;
- (id)updateTime;
@property(nonatomic, getter=isDataCelsius) _Bool dataCelsius;
@end

@interface WeatherLocationManager
+ (id)sharedWeatherLocationManager;
- (void)setLocationTrackingActive:(BOOL)arg1;
- (void)setLocationTrackingReady:(BOOL)arg1 activelyTracking:(BOOL)arg2;
- (void)setDelegate:(id)arg1;
- (id)location;
- (BOOL)locationTrackingIsReady;
@end

@interface WeatherPreferences
+ (id)sharedPreferences;
- (id)localWeatherCity;
- (void)setLocalWeatherEnabled:(BOOL)arg1;
- (BOOL)isCelsius;
@end

@interface LocationUpdater
+ (id)sharedLocationUpdater;
- (void)updateWeatherForLocation:(id)arg1 city:(id)arg2;
- (void)handleCompletionForCity:(id)arg1 withUpdateDetail:(unsigned long long)arg2;
- (void)setWeatherBadge:(id)value;
@end

@interface SBIconModel
- (id)applicationIconForDisplayIdentifier:(id)displayIdentifier;
@end

@interface SBIconViewMap
+ (id)homescreenMap;
- (id)iconModel;
@end

@interface SBIcon
- (void)setBadge:(id)badge;
@end
