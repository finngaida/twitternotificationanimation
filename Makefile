TARGET = iphone:latest:9.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TwitterNotificationAnimation
TwitterNotificationAnimation_FILES = Tweak.xm
TwitterNotificationAnimation_FRAMEWORKS = UIKit Foundation CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += settings
include $(THEOS_MAKE_PATH)/aggregate.mk
