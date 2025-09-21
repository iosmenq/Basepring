APP_NAME = Basepring
SRC = main.m AppDelegate.m ViewController.m
CC = clang

SDK = /usr/share/SDKs/iPhoneOS.sdk

CFLAGS = -fobjc-arc -isysroot $(SDK) -arch arm64
LDFLAGS = -framework UIKit -framework Foundation

all: $(APP_NAME)

$(APP_NAME): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $@ $(LDFLAGS)

clean:
	rm -f $(APP_NAME)
