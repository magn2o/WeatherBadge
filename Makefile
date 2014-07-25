TARGET := iphone:7.0:2.0
ARCHS := armv6 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeatherBadge
WeatherBadge_FILES = Tweak.xm
WeatherBadge_FRAMEWORKS = UIKit
WeatherBadge_PRIVATE_FRAMEWORKS = Weather

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = WeatherBadgeSettings
WeatherBadgeSettings_FILES = Preferences.m
WeatherBadgeSettings_INSTALL_PATH = /Library/PreferenceBundles
WeatherBadgeSettings_FRAMEWORKS = UIKit
WeatherBadgeSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WeatherBadge.plist$(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"
