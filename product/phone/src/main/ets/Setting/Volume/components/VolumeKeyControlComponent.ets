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

import Settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingItemStandard } from '@ohos/settings.common/src/main/ets/framework/view/SettingItemStandard';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemType,
  SettingItemModel,
  ItemResultType,
  ItemPos,
  ItemDetailType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  DEFAULT_VOLUME_CONTROL_KEY,
  VOLUME_CONTROL_RINGTONE_VALUE,
  VOLUME_CONTROL_MEDIA_VALUE
} from '../constant/VolumeConstant';
import { RingtonesUtils } from '../utils/RingtonesUtils';
/* instrument ignore file */
const TAG: string = 'VolumeKeyControlComponent';
const VOLUME_KEY_CONTROL_ITEM_ID: string =
  'Setting.Volume.volume_key_control.volume_key_control_mode';
const MEDIA_VOLUME_ID: string = 'volume_key_control_media';
const RINGTONE_VOLUME_ID: string = 'volume_key_control_ringtone';

@Component
export struct VolumeKeyControlComponent {
  private volumeKeyControlItems: SettingItemModel[] = [];

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.initVolumeKeyControlItems();
  }

  private initVolumeKeyControlItems(): void {
    let currentVolumeKeyControl: string = SettingsDataUtils.getSettingsData(DEFAULT_VOLUME_CONTROL_KEY,
      VOLUME_CONTROL_MEDIA_VALUE, Settings.domainName.USER_PROPERTY);
    LogUtil.info(`${TAG} initVolumeKeyControlItems with value: ${currentVolumeKeyControl}`);
    let mediaItem: SettingItemModel = this.createSettingItemModel(MEDIA_VOLUME_ID,
      $r('app.string.media_volume_message'), $r('app.string.media_volume_title'),
      currentVolumeKeyControl !== VOLUME_CONTROL_RINGTONE_VALUE);
    let ringtoneDescription: ResourceStr = !RingtonesUtils.isVoiceCapabilityDisable() ?
      $r('app.string.ringtone_volume_title') : $r('app.string.ringtone_volume_title1');
    let ringtoneItem: SettingItemModel = this.createSettingItemModel(RINGTONE_VOLUME_ID,
      $r('app.string.ringtone_volume_message'), ringtoneDescription,
      currentVolumeKeyControl === VOLUME_CONTROL_RINGTONE_VALUE);
    this.volumeKeyControlItems.push(mediaItem);
    this.volumeKeyControlItems.push(ringtoneItem);
  }

  private closeDialog(): void {
    notifyCompStateChange(VOLUME_KEY_CONTROL_ITEM_ID, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingBaseState]]
    ));
  }

  private createSettingItemModel(id: string, title: ResourceStr, description: ResourceStr,
    isChecked: boolean): SettingItemModel {
    return {
      id: id,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: title },
      desc: { content: description },
      layout: {
        accessibilityGroup: true,
        innerLeftSpace: PADDING_16,
        innerRightSpace: PADDING_16,
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        style: {
          width: 0,
          height: 0,
        },
        onItemClick: (component: SettingBaseModel) => {
          LogUtil.info(`${TAG} onItemClick with id: ${id}`);
          let volumeKeyControlValue: string = id === RINGTONE_VOLUME_ID ?
            VOLUME_CONTROL_RINGTONE_VALUE : VOLUME_CONTROL_MEDIA_VALUE;
          SettingsDataUtils.setSettingsData(DEFAULT_VOLUME_CONTROL_KEY, volumeKeyControlValue,
            Settings.domainName.USER_PROPERTY);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_KEY_DEFAULT_CONTROL,
            volumeKeyControlValue);
          this.closeDialog();
        },
      },
      result: {
        type: ItemResultType.RESULT_TYPE_RADIO,
        result: {
          checked: isChecked,
          style: {
            width: 20,
            height: 20,
          },
        },
      }
    } as SettingItemModel;
  }

  build() {
    Column() {
      ForEach(this.volumeKeyControlItems, (item: SettingItemModel, index: number) => {
        SettingItemStandard({
          itemInfo: item,
          itemPos: index === this.volumeKeyControlItems.length - 1 ? ItemPos.ITEM_POS_END : ItemPos.ITEM_POS_CENTER,
          compId: `${item.id}`
        })
      })
    }
    .width('100%');
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}