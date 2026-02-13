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

import displaySync from '@ohos.graphics.displaySync';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { PenglaiUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { DynamicGroupDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicGroupDataSource';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DisplayMeunShowUtils } from '@ohos/settings.display/src/main/ets/utils/DisplayMenuShowUtils';
import { RefreshRateUtils } from '@ohos/settings.display/src/main/ets/utils/RefreshRateUtils';
import { DisplayUtils as featureDisplayUtils} from '@ohos/settings.display/src/main/ets/DisplayUtils';
import { PageUrl } from '../../../pages/PageUrl';
import { BrightnessController } from './BrightnessController';
import { DormancySettingController } from './DormancySettingController';
import { SLEEP_TIME_STR } from '../Constant/Constant';
import { DisplayUtils } from '../utils/DisplayUtils';
import { ForcedLandscapeController } from '../controller/ForcedLandscapeController';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
/* instrument ignore file */
const TAG: string = 'DisplaySettingController';
const SETTINGS_CLONED: string = 'settingsCloned';
const DELAY_FRAME: number = 1;

export class DisplaySettingController implements ComponentControl {
  private brightnessController: BrightnessController = new BrightnessController();
  private dataSource: DynamicGroupDataSource = new DynamicGroupDataSource();
  private displaySync: displaySync.DisplaySync = displaySync.create();
  private displaySyncCount: number = 0;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    HiSysEventUtil.reportEntryEvent('enter_internal_entry', 'pageUrl: ' + PageUrl.DISPLAY_PAGE_URL);
    this.dataSource = compParam.dataSource as DynamicGroupDataSource;
    this.setDisplaySync();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.disableDisplaySync();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.INTO_DISPLAY_BRIGHTNESS);
    if (SettingsDataUtils.getSettingsData(SETTINGS_CLONED, '1') === '1') {
      displayDataManager.getDisplaySettingData();
      SettingsDataUtils.setSettingsData(SETTINGS_CLONED, '0');
    }
    AbilityUtils.pageReportCallback(TAG);
    this.onItemControllersPageShow();
  }

  private onItemControllersPageShow(): void {
    setTimeout(() => {
      this.brightnessController.onPageShow();
    }, 30);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.brightnessController.onPageHide();
  }

  private setDisplaySync() {
    this.displaySync.on('frame', this.addDataCallback);
    this.displaySync.start();
  }

  private disableDisplaySync() {
    this.displaySync.off('frame', this.addDataCallback);
  }

  private addDataCallback = (intervalInfo: displaySync.IntervalInfo) => {
    if (this.displaySyncCount === DELAY_FRAME) {
      LogUtil.info(`${TAG} second frame to show display setting groups.`);
      if (PenglaiUtil.isPengLaiModeOpen()) {
        this.addPenglaiGroups();
      } else {
        this.addNormalGroups();
      }
    }
    this.displaySyncCount++;
    if (this.displaySyncCount > DELAY_FRAME) {
      this.displaySync.stop();
    }
  };

  private addPenglaiGroups(): void {
    let groups: SettingGroupModel[] = [
      {
        id: 'screen_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: {
          id: 'screen_group_header',
          content: $r('app.string.screen'),
        },
        items: this.getPenglaiScreenItems()
      },
    ]
    this.dataSource.pushAndFilterItems(...groups);
  }

  private getPenglaiScreenItems(): SettingItemModel[]{
    if (PenglaiUtil.isPengLaiBasicModeOpen()) {
      return [
        this.dormancyItem()
      ];
    }
    return [
      this.dormancyItem(),
    ];
  }

  private addNormalGroups(): void {
    let groups: SettingGroupModel[] = [
      {
        id: 'screen_zoom',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'screen_zoom_mode',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.screen_zoom_and_text') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.SCREEN_ZOOM,
            },
          }
        ]
      },
      {
        id: 'screen_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: {
          id: 'screen_group_header',
          content: $r('app.string.screen'),
        },
        items: [
          this.dormancyItem(),
        ]
      },
      {
        id: 'forced_landscape_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'forced_landscape',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.forced_landscape') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.LANDSCAPE_STARTUP_ENTRY,
            },
            compControl: new ForcedLandscapeController(),
            needHide: () => !DisplayUtils.isDeviceSupportForcedLandscape(),
          }
        ]
      },
    ];
    this.dataSource.pushAndFilterItems(...groups);
  }

  private dormancyItem(): SettingItemModel {
    return {
      id: 'dormancy_settings',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.dormancy') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: '' },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MENU,
        icon: $r('app.media.ic_storage_spinner'),
        menu: {
          items: SLEEP_TIME_STR,
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
            DormancySettingController.onMenuChange(index);
          },
          defaultFocus: DormancySettingController.sleepTimeIndex
        }
      },
      compControl: new DormancySettingController(),
      needHide: () => {
        return SystemParamUtil.isSimulatorMode;
      },
    }
  }
}