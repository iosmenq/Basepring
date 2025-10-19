#import "ViewController.h"
#import <spawn.h>
#import <unistd.h>

extern char **environ;

@interface ViewController ()
@property (nonatomic, strong) UIButton *respringButton;
@property (nonatomic, strong) UIButton *userspaceButton;
@property (nonatomic, strong) UIButton *sbreloadButton;
@property (nonatomic, strong) UIButton *uicacheButton;
@property (nonatomic, strong) UIButton *ldrestartButton;
@property (nonatomic, strong) UIButton *safemodeButton;
@property (nonatomic, strong) UIButton *fakefsCleanerButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Jailbreak Commands";
    self.view.backgroundColor = [UIColor blackColor];

    // Buton oluştur
    self.respringButton = [self styledButtonWithTitle:@"Respring"];
    [self.respringButton addTarget:self action:@selector(respringTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.userspaceButton = [self styledButtonWithTitle:@"Userspace Reboot"];
    [self.userspaceButton addTarget:self action:@selector(userspaceTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.sbreloadButton = [self styledButtonWithTitle:@"SBReload"];
    [self.sbreloadButton addTarget:self action:@selector(sbreloadTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.uicacheButton = [self styledButtonWithTitle:@"UICache"];
    [self.uicacheButton addTarget:self action:@selector(uicacheTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.ldrestartButton = [self styledButtonWithTitle:@"LDRestart"];
    [self.ldrestartButton addTarget:self action:@selector(ldrestartTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.safemodeButton = [self styledButtonWithTitle:@"Safe Mode"];
    [self.safemodeButton addTarget:self action:@selector(safeModeTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.fakefsCleanerButton = [self styledButtonWithTitle:@"FakeFS Remover (DANGEROUS!)"];
    [self.fakefsCleanerButton addTarget:self action:@selector(fakefsCleanerTapped:) forControlEvents:UIControlEventTouchUpInside];

    // StackView
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.respringButton,
        self.userspaceButton,
        self.sbreloadButton,
        self.uicacheButton,
        self.ldrestartButton,
        self.safemodeButton,
        self.fakefsCleanerButton
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 20;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];

    // Renk animasyonları
    for (UIButton *btn in @[self.respringButton, self.userspaceButton, self.sbreloadButton, self.uicacheButton, self.ldrestartButton, self.safemodeButton, self.fakefsCleanerButton]) {
        [self startColorAnimationOnButton:btn];
    }
}

#pragma mark - Stil

- (UIButton *)styledButtonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    btn.layer.cornerRadius = 12;
    btn.layer.borderWidth = 1.0;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.contentEdgeInsets = UIEdgeInsetsMake(12, 30, 12, 30);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor darkGrayColor];
    return btn;
}

- (void)startColorAnimationOnButton:(UIButton *)button {
    CABasicAnimation *colorAnim = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnim.fromValue = (__bridge id)[UIColor colorWithRed:0.3 green:0.3 blue:1 alpha:1].CGColor;
    colorAnim.toValue = (__bridge id)[UIColor colorWithRed:1 green:0.3 blue:0.3 alpha:1].CGColor;
    colorAnim.duration = 3.0;
    colorAnim.autoreverses = YES;
    colorAnim.repeatCount = HUGE_VALF;
    [button.layer addAnimation:colorAnim forKey:@"colorPulse"];
}

#pragma mark - Aksiyonlar

- (void)respringTapped:(id)sender {
    [self runCommand:@[@"killall", @"-9", @"SpringBoard"] title:@"Respring"];
}

- (void)userspaceTapped:(id)sender {
    [self runCommand:@[@"launchctl", @"reboot", @"userspace"] title:@"Userspace Reboot"];
}

- (void)sbreloadTapped:(id)sender {
    [self runCommand:@[@"sbreload"] title:@"SBReload"];
}

- (void)uicacheTapped:(id)sender {
    [self runCommand:@[@"uicache", @"-a"] title:@"UICache -a"];
}

- (void)ldrestartTapped:(id)sender {
    [self runCommand:@[@"ldrestart"] title:@"LDRestart"];
}

- (void)safeModeTapped:(id)sender {
    // safe mode genelde backboardd veya SpringBoard'a özel sinyal göndererek tetiklenir, örnek:
    [self runCommand:@[@"killall", @"-SEGV", @"SpringBoard"] title:@"Safe Mode"];
}

- (void)fakefsCleanerTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"WARNING!!!" message:@"This will completely delete the FakeFS system. If you use it on a real rootfs, your device may enter a BOOTLOOP! Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"YES REMOVE!" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self runCommand:@[@"rm", @"-rf", @"/"] title:@"FakeFS Deleteing Please Wait..."];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Komut

- (void)runCommand:(NSArray<NSString *> *)args title:(NSString *)title {
    pid_t pid;
    const char *cmd = [args[0] UTF8String];
    int argc = (int)args.count;
    char *argv[argc + 1];
    for (int i = 0; i < argc; i++) {
        argv[i] = (char *)[args[i] UTF8String];
    }
    argv[argc] = NULL;

    int status = posix_spawnp(&pid, cmd, NULL, NULL, argv, environ);
    if (status == 0) {
        NSLog(@"%@ spawn OK (pid %d)", title, pid);
    } else {
        NSLog(@"%@ failed (errno %d)", title, status);
    }
}

@end
