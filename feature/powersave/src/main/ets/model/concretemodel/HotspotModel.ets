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
import sharing from '@ohos.net.sharing';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HotspotUtils } from '@ohos/settings.commonUikit/src/main/ets/utils/HotspotUtils';
import { PowerSaveTaskManager, TaskKey } from '../../PowerSaveTaskManager';
import { PowerSaveSuggestionModel } from '../PowerSaveSuggestionModel';

const TAG: string = 'HotspotModel';

@Concurrent
async function disableHotspot(): Promise<boolean> {
  if (!HotspotUtils.isHotspotActive()) {
    return true;
  }
  return HotspotUtils.disableHotspot();
}

async function needShow(): Promise<boolean> {
  return HotspotUtils.isHotspotActive();
}

async function generateModel(): Promise<PowerSaveSuggestionModel> {
  return {
    key: TaskKey.DISABLE_HOTSPOT,
    title: $r('app.string.turn_off_hotspot'),
    subscription: $r('app.string.turn_off_hotspot_sub'),
    cardSummary: $r('app.string.turn_off_hotspot_card_sub')
  }
}

function registerStateChange(callback: Callback<boolean>): void {
  try {
    sharing.on('interfaceSharingStateChange', (info: sharing.InterfaceSharingStateInfo) => {
      if (info?.type === sharing.SharingIfaceType.SHARING_WIFI) {
        callback(info.state === sharing.SharingIfaceState.SHARING_NIC_SERVING);
      }
    });
  } catch (error) {
    LogUtil.error(`${TAG} sharingStateChange on failed code: ${error?.code}, message: ${error?.message}`);
  }
}

function unregisterStateChange(callback: Callback<boolean>): void {
  try {
    sharing.off('interfaceSharingStateChange');
  } catch (error) {
    LogUtil.info(`${TAG} sharingStateChange off failed code: ${error?.code}, message: ${error?.message}`);
  }
}

PowerSaveTaskManager.getInstance().loadTask(TaskKey.DISABLE_HOTSPOT, {
  modelGenerator: generateModel,
  needShow: needShow,
  optimizationTask: disableHotspot,
  registerStateChange: registerStateChange,
  unregisterStateChange: unregisterStateChange
})