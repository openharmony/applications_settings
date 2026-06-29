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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  DialogButton,
  DialogLayoutStyle,
  ItemType,
  SettingDialogModel,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DIALOG_BUTTON_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ArrangeSettingsComponent } from '../component/ArrangeSettingsComponent';
import { DevicesDragDialogComponent } from '../component/DevicesDragDialogComponent';
import { DisplayConstants } from '../constant/DisplayConstant';
import { DragController } from '../controller/DragController';

/* instrument ignore file */
@Builder
function arrangeSettingsBuilder(param: object): void {
  ArrangeSettingsComponent({
    tag: 'arrangeSettings',
    title: $r('app.string.location_set'),
  })
}

export const arrangeDialogStyleModel: SettingItemModel = {
  id: 'arrange_settings',
  type: ItemType.ITEM_TYPE_CUSTOM,
  builder: wrapBuilder(arrangeSettingsBuilder),
}

@Builder
function arrangeDialogBuilder(param: object): void {
  DevicesDragDialogComponent({
    tag: 'arrangeSettings',
    title: $r('app.string.location_set'),
    tempPositionsFlag: false
  })
}

@Builder
function tempPositionsDialogBuilder(param: object): void {
  DevicesDragDialogComponent({
    tag: 'arrangeSettings',
    title: $r('app.string.location_set'),
    tempPositionsFlag: true
  })
}

function saveArrangeSettingData(): void {
  EventBus.getInstance().emit('ImageListDeviceLocationOrderChange');
  LogUtil.info(`save settingsData start`);
  DragController.getInstance().setSettingsData();
  LogUtil.info(`refresh positions start`);
  DragController.getInstance().multiPositionsRefresh().then(() => {
    LogUtil.info(`refresh positions end`);
    DragController.getInstance().setRemoteDevicePosition();
  })
}

export const buttonBlock: DialogButton = {
  value: '',
  style: { height: 0 },
  action: () => {
  }
}

export const buttonDone: DialogButton = {
  value: $r('app.string.display_azimuth_settings_finish'),
  style: {
    width: DisplayConstants.WIDTH_AUTO,
    buttonStyle: ButtonStyleMode.EMPHASIZED,
    alignSelf: ItemAlign.End,
    constraintSize: ({
      minWidth: 120,
      minHeight: 40
    }),
    padding: ({
      start: DIALOG_BUTTON_PADDING_METRICS,
      end: DIALOG_BUTTON_PADDING_METRICS
    })
  },
  action: (component: SettingItemModel) => {
    saveArrangeSettingData();
  },
}

export function arrangeSettingsDialogStyle(isSplitScreenStatus: boolean): DialogLayoutStyle {
  return {
    width: isSplitScreenStatus ?
    DisplayConstants.DEFAULT_SPLIT_SCREEN_DIALOG_WIDTH_RATE : DisplayConstants.DEFAULT_DIALOG_WIDTH,
    buttonSpaceVertical: DisplayConstants.DIALOG_BUTTON_SPACE_VERTICAL,
    padding: {
      start: PADDING_24,
      end: PADDING_24,
      bottom: PADDING_16
    },
    buttonPad: PADDING_24,
    contentButtonSpace: PADDING_16,
    titleStyle: {
      textAlign: TextAlign.Start
    }
  }
}

export function arrangeDialogStyleDialog(isSplitScreenStatus: boolean = false, tempPositionsFlag: boolean = false):
  SettingDialogModel {
  let builder = wrapBuilder(arrangeDialogBuilder);
  if (tempPositionsFlag) {
    builder = wrapBuilder(tempPositionsDialogBuilder);
  }
  return {
    contentBuilder: builder,
    title: $r('app.string.location_set'),
    buttons: [buttonDone],
    buttonVertical: false,
    style: arrangeSettingsDialogStyle(isSplitScreenStatus)
  }
}