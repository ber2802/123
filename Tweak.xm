                [g_fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@.new", g_tempFile] withIntermediateDirectories:YES attributes:nil error:nil];
                sleep(1);
                [g_fileManager removeItemAtPath:[NSString stringWithFormat:@"%@.new", g_tempFile] error:nil];
            }else {
                if ([g_fileManager fileExistsAtPath:tempPath]) [g_fileManager removeItemAtPath:tempPath error:nil];
            }
        }else {
            if ([g_fileManager fileExistsAtPath:g_tempFile]) [g_fileManager removeItemAtPath:g_tempFile error:nil];
        }
        [[%c(AVSystemController) sharedAVSystemController] setVolumeTo:0 forCategory:@"Ringtone"];
        g_downloadRunning = NO;
    };
    dispatch_async(dispatch_queue_create("download", nil), startDownload);
}
%hook VolumeControl
-(void)increaseVolume {
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970];
    if (g_volume_down_time != 0 && nowtime - g_volume_down_time < 1) {
        if ([g_downloadAddress isEqual:@""]) {
            ui_selectVideo();
        }else {
            ui_downloadVideo();
        }
    }
    g_volume_up_time = nowtime;
    %orig;
}
-(void)decreaseVolume {
    static CCUIImagePickerDelegate *delegate = nil;
    if (delegate == nil) delegate = [CCUIImagePickerDelegate new];
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970];
    if (g_volume_up_time != 0 && nowtime - g_volume_up_time < 1) {
        // 剪贴板上的分辨率信息
        NSString *str = g_pasteboard.string;
        NSString *infoStr = @"使用镜头后将记录信息";
        if (str != nil && [str hasPrefix:@"CCVCAM"]) {
            str = [str substringFromIndex:6]; //截取掉下标3之后的字符串
            // NSLog(@"获取到的字符串是:%@", str);
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:str options:0];
            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            infoStr = decodedString;
            // NSLog(@"-----=-=-=-=--=-=-%@", decodedString);
        }
        
        // 提示视频质量
        NSString *title = @"iOS-VCAM";
        if ([g_fileManager fileExistsAtPath:g_tempFile]) title = @"iOS-VCAM ✅";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:infoStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *next = [UIAlertAction actionWithTitle:@"选择视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            ui_selectVideo();
        }];
        UIAlertAction *download = [UIAlertAction actionWithTitle:@"下载视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            // 设置下载地址
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"下载视频" message:@"尽量使用MOV格式视频\nMP4也可, 其他类型尚未测试" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                if ([g_downloadAddress isEqual:@""]) {
                    textField.placeholder = @"远程视频地址";
                }else {
                    textField.text = g_downloadAddress;
                }
                textField.keyboardType = UIKeyboardTypeURL;
            }];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                //响应事件 得到文本信息
                g_downloadAddress = alert.textFields[0].text;
                NSString *resultStr = @"便捷模式已更改为从远程下载\n\n需要保证是一个可访问视频地址\n\n完成后会有系统的静音提示\n下载失败禁用替换";
                if ([g_downloadAddress isEqual:@""]) {
                    resultStr = @"便捷模式已改为从相册选取";
                }
                UIAlertController* resultAlert = [UIAlertController alertControllerWithTitle:@"便捷模式更改" message:resultStr preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"了解" style:UIAlertActionStyleDefault handler:nil];
                [resultAlert addAction:ok];
                [[GetFrame getKeyWindow].rootViewController presentViewController:resultAlert animated:YES completion:nil];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [alert addAction:cancel];
            [[GetFrame getKeyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
        }];
        UIAlertAction *cancelReplace = [UIAlertAction actionWithTitle:@"禁用替换" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            if ([g_fileManager fileExistsAtPath:g_tempFile]) [g_fileManager removeItemAtPath:g_tempFile error:nil];
        }];
        NSString *isMirroredText = @"尝试修复拍照翻转";
        if ([g_fileManager fileExistsAtPath:g_isMirroredMark]) isMirroredText = @"尝试修复拍照翻转 ✅";
        UIAlertAction *isMirrored = [UIAlertAction actionWithTitle:isMirroredText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if ([g_fileManager fileExistsAtPath:g_isMirroredMark]) {
                [g_fileManager removeItemAtPath:g_isMirroredMark error:nil];
            }else {
                [g_fileManager createDirectoryAtPath:g_isMirroredMark withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消操作" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *showHelp = [UIAlertAction actionWithTitle:@"- 查看帮助 -" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSURL *URL = [NSURL URLWithString:@"https://github.com/trizau/iOS-VCAM"];
            [[UIApplication sharedApplication]openURL:URL];
        }];
        [alertController addAction:next];
        [alertController addAction:download];
        [alertController addAction:cancelReplace];
        [alertController addAction:cancel];
        [alertController addAction:showHelp];
        [alertController addAction:isMirrored];
        [[GetFrame getKeyWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    g_volume_down_time = nowtime;
    %orig;
    // NSLog(@"减小了音量？%@ %@", [NSProcessInfo processInfo].processName, [NSProcessInfo processInfo].hostName);
    // %orig;
}
%end
%ctor {
	NSLog(@"我被载入成功啦");
    if([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){13, 0, 0}]) {
        %init(VolumeControl = NSClassFromString(@"SBVolumeControl"));
    }
    // if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] isEqual:@"com.apple.springboard"]) {
    // NSLog(@"我在哪儿啊 %@ %@", [NSProcessInfo processInfo].processName, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]);
    // }
    g_fileManager = [NSFileManager defaultManager];
    g_pasteboard = [UIPasteboard generalPasteboard];
}
%dtor{
    g_fileManager = nil;
    g_pasteboard = nil;
    g_canReleaseBuffer = YES;
    g_bufferReload = YES;
    g_previewLayer = nil;
    g_refreshPreviewByVideoDataOutputTime = 0;
    g_cameraRunning = NO;
    NSLog(@"卸载完成了");
}
