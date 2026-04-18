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
import bundleManager from '@ohos.bundle.bundleManager';
import settings from '@ohos.settings';
import { call } from '@kit.TelephonyKit';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PenglaiUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

const TAG: string = 'SystemPageMenuManager:';

const COM_ENTERPRISE_ENTERPRISE_DEVICE_MANAGER_DISPLAY: string = 'com.enterprise.enterprise_device_manager_display';
const EMERGENCY_RESCUE_ENABLE_KEY: string = 'const.emergencycommunication.enable_rescue';

export class SystemPageMenuManager {
  private static menuManager: SystemPageMenuManager | undefined = undefined;

  public static getInstance(): SystemPageMenuManager {
    if (SystemPageMenuManager.menuManager) {
      return SystemPageMenuManager.menuManager;
    }
    SystemPageMenuManager.menuManager = new SystemPageMenuManager();
    return SystemPageMenuManager.menuManager;
  }

  public isAIBarNotSupport(): boolean {
    let isHdd: string = SystemParamUtil.getParam('const.scene_board.off_personalization_feature', 'false');
    return isHdd === 'true';
  }

  public isSOSEmergencyHelpNotSupport(): boolean {
    let sosEmergencyHelpBundleName: string = 'com.ohos.emergencycommunication';

    try {
      if (DeviceUtil.isDevicePad() && !call.hasVoiceCapability()) {
        return true;
      }
    } catch (err) {
      LogUtil.error(`${TAG} get sDevicePad or hasVoiceCapability failed: ${err?.message}`);
    }

    try {
      bundleManager.getBundleInfoSync(sosEmergencyHelpBundleName, bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
      return false;
    } catch (err) {
      LogUtil.error(`${TAG} get SOSEmergencyHelp bundleInfo failed: ${err?.message}`);
    }
    return true;
  }

  public isEnterpriseDeviceNotSupport(): boolean {
    let context: Context = AppStorage.get<Context>('pageContext') as Context;
    let deviceManagerDisplay: string = 'false';
    try {
      deviceManagerDisplay = settings.getValueSync(context,
        COM_ENTERPRISE_ENTERPRISE_DEVICE_MANAGER_DISPLAY, 'false');
    } catch (e) {
      LogUtil.error(`${TAG} settings getValueSync err`);
    }
    if (deviceManagerDisplay === 'true') {
      return false;
    }
    try {
      let developerInfoArr = bundleManager.getDeveloperIds(bundleManager.AppDistributionType.ENTERPRISE);
      return developerInfoArr.length === 0;
    } catch (err) {
      LogUtil.error(`${TAG} bundleManager.getDeveloperIds fail: ${err?.message}`);
    }

    return true;
  }

  public isDevelopOptionNotSupport(): boolean {
    let developerStatus: string = SystemParamUtil.getParam('const.security.developermode.state', 'false');
    return developerStatus === 'false';
  }

  public isDragSupport(): boolean {
    LogUtil.info(`${TAG} DeviceUtil.isDevicePad(): ${DeviceUtil.isDevicePad()}`);
    if (DeviceUtil.isDevicePad()) {
      return true;
    } else if (DeviceUtil.isDevicePhone() || DeviceUtil.isFoldable()) {
      return false;
    }
    return true;
  }

  public isPengLaiLightWeightModeNotSupported(): boolean {
    return !PenglaiUtil.isPengLaiModeSupported();
  }

  public isGripPostureFollowNotSupported(): boolean {
    let isGripFollowSupported: boolean = SystemParamUtil.getParam('persist.systemui.liveSideCard', '') === 'true';
    return !isGripFollowSupported;
  }
}