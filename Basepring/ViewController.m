#import "ViewController.h"
#import <spawn.h>
#import <unistd.h>

extern char **environ;

@interface ViewController ()
@property (nonatomic, strong) UIButton *respringButton;
@property (nonatomic, strong) UIButton *userspaceButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Respring Tool";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // Respring butonu
    self.respringButton = [self styledButtonWithTitle:@"Respring"];
    [self.respringButton addTarget:self action:@selector(respringTapped:) forControlEvents:UIControlEventTouchUpInside];

    // Userspace reboot butonu
    self.userspaceButton = [self styledButtonWithTitle:@"Userspace Reboot"];
    [self.userspaceButton addTarget:self action:@selector(userspaceTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.respringButton, self.userspaceButton]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 20;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (UIButton *)styledButtonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    btn.layer.cornerRadius = 12;
    btn.layer.borderWidth = 1.0;
    btn.layer.borderColor = [UIColor systemBlueColor].CGColor;
    btn.contentEdgeInsets = UIEdgeInsetsMake(12, 30, 12, 30);
    return btn;
}

#pragma mark - Actions

- (void)respringTapped:(id)sender {
    [self runCommand:@[@"killall", @"-9", @"SpringBoard"] title:@"Respring"];
}

- (void)userspaceTapped:(id)sender {
    [self runCommand:@[@"launchctl", @"reboot", @"userspace"] title:@"Userspace Reboot"];
}

- (void)runCommand:(NSArray<NSString *> *)args title:(NSString *)title {
    pid_t pid;
    const char *cmd = [args[0] UTF8String];

    // argv oluştur
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
