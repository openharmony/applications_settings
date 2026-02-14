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
import { NavEntryKey, PasswordUtil } from '@ohos/settings.common';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageComponent } from '../../../component/PageComponent';
import { AccountConstants } from '../common/constants/AccountConstants';
import { PasswordTypeConstants } from '../common/constants/PasswordTypeConstants';
import { CheckPriPwdHome } from '../component/checkpwd/CheckPriPwdHome';
import { CheckPasswordProtect } from '../component/passwordprotect/CheckPasswordProtect';
import { SetPasswordProtectView } from '../component/passwordprotect/SetPasswordProtect';
import { UpdatePrivatePwdMixType } from '../component/updatepwd/UpdatePrivatePwdMixType';
import { UpdatePrivatePwdNumberType } from '../component/updatepwd/UpdatePrivatePwdNumberType';
import { UpdatePrivatePwdPinType } from '../component/updatepwd/UpdatePrivatePwdPinType';
import { CommonConstants } from '../common/constants/CommonConstants';
import { HiSysEventUtil } from '../common/utils/HiSysEventUtil';
import SecurityManager from '../security/SecurityManager';
import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit';

const TAG: string = 'ChangeQA';

/**
 * 隐私密码-更改密保问题
 *
 * @since 2024-11-27
 */
@Builder
export function ChangeQALoader($$: Params): void {
  ChangeQA();
}

@Component
export struct ChangeQA {
  @Provide('pageInfos') innerPathInfos: NavPathStack = new NavPathStack();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State maxPasswordLength: number = AccountConstants.SIX_PIN_PASSWORD_LENGTH;
  @State passwordType: number = PasswordTypeConstants.PRIVATE_SPACE_PIN_TYPE;
  @State isNeedPop: boolean = true;
  @State @Watch('onBackUpdate') isChecked: boolean = false;
  @State @Watch('onResetPwd') forgetPwdCheck: boolean = false;
  @State credentialId: Uint8Array = new Uint8Array();
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
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
    SecurityManager.getInstance().clearCredential();
  }

  onBackUpdate(): void {
    if (this.isChecked) {
      this.innerPathInfos.pushPathByName('setPasswordProtect', null);
    }
  }

  onResetPwd(): void {
    if (this.forgetPwdCheck) {
      this.innerPathInfos.pushPathByName('updatePrivatePwdPinType', null);
    }
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
      onPageShow: () => {
        this.innerPathInfos.pushPathByName('checkPriPwdHome', null)
        PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage),
          true);
        this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
      },
      onHidden: () => {
        this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
        PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage),
          false);
        this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
      }
    })
  }

  @Builder
  myRouter(name: string) {
    // verify页面 -> verify页面做判断
    if (name === 'checkPriPwdHome') {
      CheckPriPwdHome({
        isNeedPop: this.isNeedPop,
        isChecked: this.isChecked,
        credentialId: this.credentialId
      })
    } else if (name === 'setPasswordProtect') {
      SetPasswordProtectView()
    } else if (name === 'checkPasswordProtect') {
      CheckPasswordProtect({
        isChecked: this.forgetPwdCheck
      })
    } else if (name === 'updatePrivatePwdPinType') {
      UpdatePrivatePwdPinType({
        passwordType: this.passwordType,
        isNeedPop: this.isNeedPop
      })
    } else if (name === 'updatePrivatePwdNumberType') {
      UpdatePrivatePwdNumberType({
        passwordType: this.passwordType,
        isNeedPop: this.isNeedPop
      })
    } else if (name === 'updatePrivatePwdMixType') {
      UpdatePrivatePwdMixType({
        passwordType: this.passwordType,
        isNeedPop: this.isNeedPop
      })
    }
  }

  @Builder
  buildPageContent() {
    HdsNavigation(this.innerPathInfos) {
    }
    .navDestination(this.myRouter)
    .mode(NavigationMode.Stack)
  }
}
