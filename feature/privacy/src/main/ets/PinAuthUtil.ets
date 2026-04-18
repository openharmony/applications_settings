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
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import SecurityContext from '@ohos/settings.common/src/main/ets/context/SecurityContext';
import { AuthConstant } from '@ohos/settings.common/src/main/ets/constant/AuthConstant';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';

export class PinAuthUtil {
  public static TAG: string = 'PinAuthUtil: ';

  public static hasChallenge(params: PushParam | undefined): boolean {
    let configRecord: Record<string, string> = (params?.config as Record<string, string>);
    return params != null && params.config != null && configRecord[AuthConstant.CHALLENGE] != null &&
      configRecord[AuthConstant.CHALLENGE] !== '';
  }

  public static isFromUIExtension(params: PushParam | undefined | null): boolean {
    let configRecord: Record<string, string> = (params?.config as Record<string, string>);
    return params != null && params.config != null && configRecord[AuthConstant.SOURCE_FROM] != null &&
      configRecord[AuthConstant.SOURCE_FROM] === AuthConstant.FROM_UIEXTENSION;
  }

  public static isDialogShowInSubWindow(params: PushParam | undefined | null): boolean {
    let configRecord: Record<string, boolean> = (params?.config as Record<string, boolean>);
    if (params != null && params.config != null) {
      return configRecord[AuthConstant.isDialogShowInSubWindow] === false ? false : true;
    }
    return true;
  }

  public static challenge2Token(challenge: string, result: number): void {
    LogUtil.info(`${PinAuthUtil.TAG} in challenge2Token.`);
    PasswordUtil.challengeAuthPin(challenge).then(() => {
      LogUtil.info(`${PinAuthUtil.TAG} challengeAuthPin auth success`);
      AbilityUtils.closeUiExtensionWithData(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'),
        result, { 'token': PasswordUtil.uint8ArrayToBase64String(SecurityContext.getInstance().getToken()) });
    }).catch(() => {
      LogUtil.error(`${PinAuthUtil.TAG} challengeAuthPin auth failed`);
    })
    PasswordUtil.unregisterInputer();
  }

  public static getParamValue(params: PushParam | undefined, key: string): string {
    let configRecord: Record<string, string> = (params?.config as Record<string, string>);
    return configRecord[key];
  }
}