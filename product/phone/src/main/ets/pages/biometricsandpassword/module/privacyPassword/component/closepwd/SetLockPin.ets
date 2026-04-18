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
import { Want } from '@kit.AbilityKit';
import { HiSysEventConstants } from '../../common/constants/HiSysEventConstants';
import { getCredentials, usePinProtection } from '../../common/PrivacyPassword';
import { HiSysEventUtil } from '../../common/utils/HiSysEventUtil';
import Log from '../../common/utils/Log';
import { PasswordUtils } from '../../common/utils/PasswordUtils';

const TAG = 'SetAuthPage';
const SET_AUTH_SUCCESS_CODE = 0;

interface TokenData {
  token: string;
}

export interface ReceiveResult {
  result: number;
  data: TokenData;
}

/**
 * SetAuthPage
 *
 * @since 2024-04-09
 */
@Component
export struct SetLockPin {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Consume('innerPathInfos') innerPathInfos: NavPathStack;
  want: Want = {
    bundleName: 'com.ohos.settings',
    abilityName: 'PasswordSettingExtensionAbility',
    parameters: {
      'ability.want.params.uiExtensionType': 'sysDialog/common',
      'pushParams': {
        'challenge': '',
        'token': '',
        'hasSession': true,
        'from': 'UIExtension'
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        UIExtensionComponent(this.want)
          .defaultFocus(true)
          .size({ width: '100%', height: '100%' })
          .onReceive((callBackResult: object) => {
            const result = callBackResult as ReceiveResult;
            if (result?.result === SET_AUTH_SUCCESS_CODE) {
              Log.info(TAG, 'onReceive');
              usePinProtection().then(async (res) => {
                const credentials = await getCredentials();
                const deleteList = [HiSysEventConstants.DELETE_LIST];
                const deleteWay = [HiSysEventConstants.USE_SCREEN_PIN_PROTECT];
                const deleteResult = await PasswordUtils.deletePassword();
                if (deleteResult) {
                  PasswordUtils.clearQuestionInDb(getContext(this));
                  credentials.forEach((cred) => {
                    HiSysEventUtil.reportDeleteEvent(cred.credentialId, cred.templateId, cred.authSubType, deleteList,
                      deleteWay);
                  })
                }
                HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_DELETE,
                  HiSysEventConstants.USER_OPERATION_END);
                this.pathInfos?.pop();
              });
            } else {
              this.innerPathInfos.pop();
            }
          })
          .backgroundColor(Color.Transparent)
      }
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .height('100%')
  }
}