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

import a2dp from '@ohos.bluetooth.a2dp';
import { SingleChoiceListController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SingleChoiceEntryMenu, SingleSelectMenuItem } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  BLUETOOTH_AUDIO_BITRATE_MAP,
  BLUETOOTH_AUDIO_BITRATE_MONO_LIST,
  BLUETOOTH_AUDIO_BITRATE_STEREO_LIST,
  BLUETOOTH_AUDIO_BITS_PER_SAMPLE_MAP,
  BLUETOOTH_AUDIO_CHANNEL_MODE_MAP,
  BLUETOOTH_AUDIO_DECODER_MAP,
  BLUETOOTH_AUDIO_FRAME_LENGTH_MAP,
  BLUETOOTH_AUDIO_SAMPLING_RATE_MAP
} from '../utils/BluetoothAudioConsts';
import { CodecInfoManager } from '../utils/CodecInfoManager';
/* instrument ignore file */
export const DECODER_METHOD_CHANGE: string = 'DECODER_METHOD_CHANGE';

export const CODEC_CHANNEL_MODE_CHANGE: string = 'CODEC_CHANNEL_MODE_CHANGE';

abstract class DefaultController extends SingleChoiceListController {
  protected TAG: string = 'DefaultController :';
  protected currentSelected: number | undefined = undefined;
  protected itemAllList: Array<number> = [];
  protected decoderTypeChangeCallBack = (key: number) => {
    LogUtil.info(`${this.TAG} decoderTypeChangeCallBack`);
    this.generateItemAllList();
    this.updateStatus();
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  public getObserverKey = (): string => {
    return this.menu?.key ?? '';
  }

  abstract getNameByValue(value: number | undefined): ResourceStr;

  abstract updateCurrentSelected(): void;

  abstract generateItemAllList(): void;

  onBindMenuAppear() {
    this.openSelectMenu();
  }

  private openSelectMenu(): void {
    if (this.menu instanceof SingleChoiceEntryMenu) {
      this.menu.singleChoiceData = this.generateSelectMenu();
    }
  }

  private generateSelectMenu(): Array<SingleSelectMenuItem> {
    LogUtil.info(`${this.TAG} generateSelectMenu start`);
    let singleChoiceData: SingleSelectMenuItem[] = [];
    this.itemAllList?.forEach(value => {
      let menu: SingleSelectMenuItem = {
        key: value?.valueOf(),
        title: this.getNameByValue(value),
        isSelect: value === this.currentSelected,
      };
      singleChoiceData.push(menu);
    })
    return singleChoiceData;
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear`);
    EventBus.getInstance().on(DECODER_METHOD_CHANGE, this.decoderTypeChangeCallBack);
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    super.aboutToDisappear();
    EventBus.getInstance().detach(DECODER_METHOD_CHANGE, this.decoderTypeChangeCallBack);
  }

  updateStatus(): void {
    LogUtil.info(`${this.TAG} updateStatus start`);
    this.updateCurrentSelected();
    if (CodecInfoManager.getInstance().getCodecInfo()) {
      this.menu.enable = true;
      this.menu.state = this.getNameByValue(this.currentSelected);
      this.openSelectMenu();
    } else {
      this.menu.enable = false;
    }
    this.refreshUi();
    LogUtil.info(`${this.TAG} updateStatus this.menu.state:${this.menu.state}`);
  }

  onSelectMenuChanged(key: number): void {
    this.currentSelected = key;
    LogUtil.info(`${this.TAG} onSelectMenuChanged setCodecInfoData = ${this.currentSelected}`);
    CodecInfoManager.getInstance().updateCodecInfo();
    this.updateStatus();
  }
}
