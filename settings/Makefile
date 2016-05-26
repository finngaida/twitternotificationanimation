include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TwitterNotificationAnimation
TwitterNotificationAnimation_FILES = FGARootListController.m
TwitterNotificationAnimation_INSTALL_PATH = /Library/PreferenceBundles
TwitterNotificationAnimation_FRAMEWORKS = UIKit
TwitterNotificationAnimation_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TwitterNotificationAnimation.plist$(ECHO_END)
