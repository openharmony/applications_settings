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

/* instrument ignore file */
import { KeyboardAvoidMode, window } from '@kit.ArkUI';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageComponent } from '../../../component/PageComponent';
import { CommonConstants } from '../common/constants/CommonConstants';
import { HiSysEventUtil } from '../common/utils/HiSysEventUtil';
import { changePrivacySearchItem } from '../common/PrivacyPassword';

const SET_AUTH_SUCCESS_CODE = 1;
const SET_AUTH_CANCEL_CODE = 0;

export interface ReceiveResult {
  resultCode: number;
}

/**
 * 隐私密码-设置隐私密码
 *
 * @since 2024-11-27
 */
@Builder
export function SetPrivacyPasswordLoader($$: Params): void {
  SetPrivacyPassword();
}

@Component
export struct SetPrivacyPassword {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  TAG = 'SetPrivacyPassword';
  @Consume('pathInfos') pathInfos: NavPathStack;
  want: Want = {
    bundleName: 'com.ohos.useriam.idmwidget',
    abilityName: 'PrivatePinAbility',
    parameters: {
      'ability.want.params.uiExtensionType': 'sys/commonUI',
      'pushParams': {
        'type': 1
      }
    }
  };
  private timer: number | undefined = undefined;

  aboutToAppear(): void {
    this.timer = setInterval(() => {
      this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
      PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage),
        false);
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
    }, CommonConstants.TEN_MIN_IN_MILE_SECOND);
    HiSysEventUtil.initData();
  }

  aboutToDisappear(): void {
    clearInterval(this.timer);
  }

  build() {
    PageComponent({
      content: () => {
        this.buildPageContent()
      },
      paddingTop: '0vp',
      paddingLeft: '0vp',
      paddingRight: '0vp',
      hideTitle: true,
      onBackPress: () => {
        return true;
      },
      onHidden: () => {
        this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
        PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage),
          false);
        this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
      },
      onPageShow: () => {
        PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage),
          true);
        this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
      }
    })
  }

  @Builder
  buildPageContent() {
    Row() {
      Column() {
        UIExtensionComponent(this.want)
          .defaultFocus(true)
          .size({ width: '100%', height: '100%' })
          .onRemoteReady((_proxy: UIExtensionProxy) => {
            LogUtil.info(`${this.TAG}, onRemoteReady`);
          })
          .onReceive((callBackResult: object) => {
            if ((callBackResult as ReceiveResult)?.resultCode === SET_AUTH_CANCEL_CODE) {
              this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
            } else if ((callBackResult as ReceiveResult)?.resultCode === SET_AUTH_SUCCESS_CODE) {
              changePrivacySearchItem();
              this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
            }
          })
          .onError((_error) => {
            LogUtil.error(`${this.TAG}, onError code: ${_error?.code}`);
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .backgroundColor($r('sys.color.background_secondary'))
    }
  }
}
