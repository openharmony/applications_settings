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

import { PADDING_6 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { STORAGE_DATA_UPDATE_EVENT } from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { HiSysStorageEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import DataPanelModel from '../model/DataPanelModel';

/* instrument ignore file */
const TAG = 'DataPanelComponent';
const SYSTEM_COLOR_MODE: string = 'colorMode';
const VALUE_COLORS_LIGHT = ['#4B8AF3', '#F7CE00', '#F772AC', '#A575EB', '#73C1E6', '#A2A2B0'];
const VALUE_COLORS_DARK = ['#4C81D9', '#D1A738', '#D5749E', '#9973D1', '#5EA6D1', '#8C8C99'];
const LARGE_FONT_MODE_PADDING_VERTICAL: number = 8;
const LARGE_FONT_MODE_PADDING_HORIZONTAL: number = 10;

@Builder
export function dataPanelBuilder(param: object): void {
  DataPanelComponent();
}

@Component
export struct DataPanelComponent {
  tag: string = 'DataPanelComponent : ';
  menu?: SettingsBaseMenu;
  @State panelData: DataPanelModel = {};
  @State message: string = '';
  @State isLightMode: boolean = true;
  @State isLoading: boolean = true;
  @State valueColor: ResourceStr[] = [];
  private storageDataUpdateCallback = (data: DataPanelModel) => {
    this.isLoading = true;
    setTimeout(() => {
      this.panelData = data;
      this.message = this.panelData?.message ?? '';
      LogUtil.info(`${TAG} emitter.on success, EVENT_ID: ${STORAGE_DATA_UPDATE_EVENT}}`);
      this.isLoading = false;
    }, 0);
  }

  build() {
    Flex() {
      Column() {
        Flex({
          direction: FlexDirection.Row,
          wrap: FlexWrap.Wrap,
          justifyContent: FlexAlign.SpaceBetween,
          alignItems: ItemAlign.Center
        }) {
          Text(`${this.getUsedProportion().toString()}`)
            .fontSize($r('sys.float.Title_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.icon_primary'))
            .margin({ right: '2vp' })
            .constraintSize({
              minHeight: 40,
            })
        }
        .width('100%')

        Row() {
          Text(`${this.message}`)
            .fontSize($r('sys.float.Subtitle_S'))
            .alignSelf(ItemAlign.Start)
            .fontColor($r('sys.color.icon_primary'))
            .opacity($r('sys.float.alpha_secondary'))
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        this.dataPanel();
        this.getLegends();
      }
      .padding({
        left: 8,
        right: 8,
        top: 20,
        bottom: 20
      })
    }
  }

  @Builder
  dataPanel(): void {
    Column({ space: 5 }) {
      DataPanel(this.isLoading ? {
        values: this.getValues(),
        max: this.panelData?.totalValue,
        type: DataPanelType.Line
      } : { values: this.getValues(), max: this.getTotalValue(), type: DataPanelType.Line })
        .align(Alignment.Center)
        .width('100%')
        .height(38)
        .valueColors(this.getValueColors())
        .backgroundColor($r('sys.color.comp_background_secondary'))
        .closeEffect(true)
    }
    .border({ radius: 8 })
    .margin({ top: 12, bottom: 10 })
    .clip(true)
  }

  @Builder
  getLegends(): void {
    Row({ space: 12 }) {
      if (this.isLoading) {
        Flex({ alignItems: ItemAlign.Center }) {
          Circle({ width: 8, height: 8 })
            .fill($r('sys.color.icon_tertiary'))
            .margin({ end: PADDING_6 })
          Text($r('app.string.storage_calculating_size'))
            .fontSize($r('sys.float.Caption_M'))
        }
      } else {
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
          ForEach(this.panelData?.legendNames, (item: string, index: number) => {
            Row({ space: 6 }) {
              Circle({ width: 8, height: 8 })
                .fill(this.valueColor[index])
              Text(item)
                .fontSize($r('sys.float.Caption_M'))
            }.margin({ right: 12 })
          })
        }
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  aboutToAppear(): void {
    ResourceUtil.getAnyStrFormatString($r('app.string.used_data'), '0 GB', '0 GB')
      .then((message: string) => {
        this.message = message;
      });
    this.message === '';
    EventBus.getInstance().on(STORAGE_DATA_UPDATE_EVENT, this.storageDataUpdateCallback);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(STORAGE_DATA_UPDATE_EVENT, this.storageDataUpdateCallback);
  }

  getUsedProportion(): number | string {
    return this.panelData?.proportion ?? '';
  }

  getValues(): number[] {
    return this.panelData?.categoryValues ?? [];
  }

  getTotalValue(): number {
    return this.panelData?.totalValue ?? 1;
  }

  getMessage(): string {
    return this.panelData?.message ?? '';
  }

  getValueColors(): ResourceColor[] {
    let colorModel = PreferencesUtil.getSync(SYSTEM_COLOR_MODE, '');
    LogUtil.info(`${TAG} colorModel:${colorModel}, this.isLightMode : ${this.isLightMode}}`);
    this.isLightMode = (colorModel === 0) ? false : true;
    this.valueColor = this.isLightMode ? VALUE_COLORS_LIGHT : VALUE_COLORS_DARK;
    return this.valueColor;
  }
}