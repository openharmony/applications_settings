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
import { DeviceUtil, ResourceUtil } from '@ohos/settings.common';
import { BusinessError } from '@ohos.base';
import { window } from '@kit.ArkUI';
import { osAccount } from '@kit.BasicServicesKit';
import { CheckMixedAndNumberPwd } from './CheckMixedAndNumberPwd';
import { CheckPinPwd } from './CheckPinPwd';
import { currentPwdType } from '../../common/PrivacyPassword';
import Log from '../../common/utils/Log';
import { HiSysEventUtil } from '../../common/utils/HiSysEventUtil';
import { HiSysEventConstants } from '../../common/constants/HiSysEventConstants';
import { PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  HdsNavDestinationTitleMode, HdsNavDestination, HdsNavDestinationAttribute, DividerShowType
} from '@kit.UIDesignKit';

const TAG = 'CheckPriPwdHome';

@Component
export struct CheckPriPwdHome {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Consume('innerPathInfos') innerPathInfos: NavPathStack;
  @Link isNeedPop: boolean;
  @Link isChecked: boolean;
  @Link credentialId?: Uint8Array;
  @State @Watch('onForgetPwdShow') forgetPwd: boolean = false;
  @State keyboardHeight: number = 0;
  @State authSubType: osAccount.AuthSubType = osAccount.AuthSubType.PIN_SIX;
  @State transitionType: NavigationSystemTransitionType = NavigationSystemTransitionType.DEFAULT;

  onForgetPwdShow(): void {
    if (this.forgetPwd) {
      this.innerPathInfos.pushPathByName('checkPasswordProtect', null);
    }
    this.forgetPwd = false;
  }

  aboutToAppear(): void {
    Log.info(TAG, 'aboutToAppear')
    this.transitionType = NavigationSystemTransitionType.TITLE;
    this.loadPageData();
  }

  aboutToDisappear(): void {
    window.getLastWindow(getContext(this)).then((win) => {
      try {
        win.off('avoidAreaChange');
      } catch (e) {
        Log.error(TAG, `win.off error: ${e?.code} ${e?.message}`);
      }
    })
      .catch((err: BusinessError)=>{
        Log.error(TAG, `aboutToAppear error: ${err?.code} ${err?.message}`);
      })
  }

  build() {
    NavDestination() {
      Column() {
        if (this.authSubType === osAccount.AuthSubType.PIN_SIX) {
          CheckPinPwd({
            isNeedPop: this.isNeedPop,
            isChecked: this.isChecked,
            forgetPwd: this.forgetPwd,
            credentialId: this.credentialId
          })
        } else {
          CheckMixedAndNumberPwd({
            isNeedPop: this.isNeedPop,
            isChecked: this.isChecked,
            authPinType: this.authSubType,
            forgetPwd: this.forgetPwd,
            credentialId: this.credentialId
          })
        }
      }
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .title(this.authSubType === osAccount.AuthSubType.PIN_SIX ?
             ResourceUtil.getStringSync($r('app.string.verify_privacy_pin'))
               : ResourceUtil.getStringSync($r('app.string.verify_privacy_password')))
    // .titleMode(HdsNavDestinationTitleMode.MINI)
    // .titleBar({
    //   enableComponentSafeArea: true,
    //   content: {
    //     title: {
    //       mainTitle: this.authSubType === osAccount.AuthSubType.PIN_SIX ?
    //         ResourceUtil.getStringSync($r('app.string.verify_privacy_pin'))
    //           : ResourceUtil.getStringSync($r('app.string.verify_privacy_password')),
    //     },
    //     divider: {
    //       showType: DividerShowType.OFF
    //     }
    //   },
    //   style: {
    //     originalStyle: {
    //       backgroundStyle: {
    //         backgroundColor: $r('sys.color.comp_background_gray'),
    //       },
    //     },
    //     scrollEffectStyle: {
    //       backgroundStyle: {
    //         backgroundColor: $r('sys.color.comp_background_gray'),
    //       },
    //     },
    //   },
    //   padding: {
    //     start: DeviceUtil.isDevicePhone() ? PADDING_16 : PADDING_24,
    //     end: DeviceUtil.isDevicePhone() ? PADDING_16 : PADDING_24,
    //   }
    // })
    .systemTransition(this.transitionType)
    .onBackPressed(() => {
      this.transitionType = NavigationSystemTransitionType.TITLE;
      this.pathInfos.pop();
      HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PWD,
        HiSysEventConstants.USER_OPERATION_CANCEL)
      return true;
    })
    .onShown(()=> {
      Log.info(TAG, `onShown`);
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
    })
    .onReady((ctx: NavDestinationContext) => {
      this.innerPathInfos = ctx.pathStack;
    })
    .accessibilityLevel(this.enableAccessibility())
  }

  private enableAccessibility(): string {
    return this.isChecked ? 'no' : 'yes'
  }

  private async loadPageData(): Promise<void> {
    try {
      this.authSubType = await currentPwdType();
      window.getLastWindow(getContext(this)).then((win) => {
        win.on('avoidAreaChange', data => {
          if (data.type !== window.AvoidAreaType.TYPE_KEYBOARD) {
            return;
          }
          this.keyboardHeight = px2vp(data.area.bottomRect.height);
        });
      })
    } catch (e) {
      Log.error(TAG, 'load CheckPriPwdHome Data error' + e.message)
    }
  }
}