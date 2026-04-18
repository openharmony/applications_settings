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

import Want from '@ohos.application.Want';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { hasOwnPropertyCall } from '@ohos/settings.common/src/main/ets/utils/ObjectPrototypeUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';

/* instrument ignore file */
const TAG: string = 'BLUETOOTH_SWITCH_DIALOG';

export default class BluetoothSwitchAbility extends UIExtensionAbility {
  onCreate(): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityContextManager.addContext(this.context);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionCreate is called`);
    if (!this.isParamsValid(want) || CheckEmptyUtils.isEmpty(session)) {
      LogUtil.error(`${TAG} want or session is invalid`);
      session?.terminateSelf();
      return;
    }

    AppStorage.setOrCreate<UIExtensionContentSession>('dialogSession', session);
    let bundleInfo: bundleManager.BundleInfo;
    try {
      bundleInfo = bundleManager.getBundleInfoSync(want.parameters?.bundleName,
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    } catch (errData) {
      LogUtil.error(`${TAG} getBundleInfoSync errData is errCode: ${errData?.code}  message:${errData?.message}`);
      session?.terminateSelf();
      return;
    }

    if (!bundleInfo?.appInfo?.label || !bundleInfo?.appInfo?.labelId) {
      LogUtil.error(`${TAG} bundleInfo error, label: ${bundleInfo?.appInfo?.label}, labelId:${bundleInfo?.appInfo?.labelId}`);
      session?.terminateSelf();
      return;
    }

    LogUtil.info(`${TAG} getBundleInfoSync label:${bundleInfo?.appInfo?.label}, labelId:${bundleInfo?.appInfo?.labelId}`);
    ResourceManagerUtil.getBundleResourceManager(bundleInfo.name)?.getStringValue(bundleInfo?.appInfo?.labelId)
      .then((label) => {
      AppStorage.setOrCreate<string>('BluetoothBundleName', label);
      AppStorage.setOrCreate<string>('bluetoothSwitchType', want.parameters?.type);

      session?.loadContent('Setting/Bluetooth/dialog/view/BluetoothSwitchDialog');
      session?.setWindowBackgroundColor('#00FFFFFF');
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getStringValue error, label: ${bundleInfo?.appInfo?.label} err: ${err?.message}`);
      session?.terminateSelf();
    });
    LogUtil.info(`${TAG} onSessionCreate is end`);
  }

  private isParamsValid(want: Want): boolean {
    LogUtil.info(`${TAG} bundleName: ${want.parameters?.bundleName}, type:${want.parameters?.type}}`);
    if (CheckEmptyUtils.isEmpty(want) || !hasOwnPropertyCall(want, 'bundleName') || !hasOwnPropertyCall(want, 'type')) {
      LogUtil.error(`${TAG} onSessionCreate want parameters invalid, terminate self`);
      return false;
    }
    let type: string = want.parameters?.type;
    if ('enable' !== type && 'disable' !== type) {
      LogUtil.error(`${TAG} want parameters invalid, error type:${type}`);
      return false;
    }
    return true;
  }
}
