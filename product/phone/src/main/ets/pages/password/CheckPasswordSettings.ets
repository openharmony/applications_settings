/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import window from '@ohos.window';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { MenuTitlePageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckPasswordPage } from './model/CheckPasswordPage';
import { CreatePsdParams } from './model/CreatePsdPage';
import { CHANGE_PASSWORD_ENTRY_FLAG, DISABLE_OLD_PASSWORD_ENTRY_FLAG } from './controller/PasswordEntryController';
import { PasswordUtil, PinSubType, ResultCode } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
/* instrument ignore file */

/**
 * 关闭锁屏密码
 *
 * @since 2023-01-13
 */
@Builder
export function CheckPasswordSettingsLoader($$: Params): void {
  CheckPasswordSettings({ params: $$ as Object as PushParam });
}

@Component
export struct CheckPasswordSettings {
  private TAG: string = 'CheckPasswordSettings : ';
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner);
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State title: ResourceStr = '';

  build() {
    NavDestination() {
      Column() {
        MenuTitlePageComponent({ menuPage: this.pageRoot.menuPage, title: this.title });
      }
      .size({ width: '100%', height: '100%' })
    }
    .title(this.title)
    // .titleBar({
    //   enableComponentSafeArea: true,
    //   content: {
    //     title: {
    //       mainTitle: this.title
    //     }
    //   }
    // })
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear`);
    PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), true);
    this.pageRoot.aboutToAppear(new CheckPasswordPage(this.pathInfos, this.params as PushParam));
    this.initTitle();
  }

  private initTitle(): void {
    PasswordUtil.getAuthProperty((data) => {
      let isMixPwd: boolean = false;
      if (data?.result === ResultCode.SUCCESS && data.authSubType?.toString() === PinSubType.PIN_PATTERN.toString()) {
        this.title = $r('app.string.drawing_pattern_password');
        return;
      } else if (data?.result === ResultCode.SUCCESS &&
        data.authSubType?.toString() === PinSubType.PIN_MIXED.toString()) {
        isMixPwd = true;
      }
      let param: PushParam = this.params as PushParam;
      let source: string = (param.config as CreatePsdParams).source;
      if (source === CHANGE_PASSWORD_ENTRY_FLAG || source === DISABLE_OLD_PASSWORD_ENTRY_FLAG) {
        this.title = isMixPwd ? $r('app.string.enter_current_lock_screen_password_title') :
        $r('app.string.enter_current_lock_screen_pin_title');
      } else {
        this.title = isMixPwd ? $r('app.string.enter_lock_screen_password_title') :
        $r('app.string.enter_lock_screen_pin_title');
      }
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    PasswordUtil.setWindowNonPrivacyModeIfNeed((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), this.pathInfos);
  }

  onPageShow(): void {
    LogUtil.info(`${this.TAG} onPageShow`);
    this.pageRoot.onPageShow();
    WindowManager.getInstance().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  onPageHide(): void {
    LogUtil.info(`${this.TAG} onPageHide`);
    this.pageRoot.onPageHide();
    WindowManager.getInstance().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }
}