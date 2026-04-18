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
import { dataShare } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { i18n, intl } from '@kit.LocalizationKit';
import wifiManager from '@ohos.wifiManager';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingDialogState,
  SettingModalState,
  SettingStateType,
  SettingTextState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  HiSysHotspotEventGroup,
  HiSysUpdateAPBANDEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { URL_HOTSPOT_LIMIT_SHEET_PAGE } from '../../HostpotLimitSheetPage';
import { ApBand } from '../constants/HotSpotConstants';
import { HotspotLimitDataManager, USER_DATA_NO_LIMIT } from '../HotspotLimitDataManager';
import {
  DATA_LIMIT_KEY,
  HotSpotUtils,
  NEED_DIALOG_KEY,
  NEED_DIALOG_VALUE,
  NO_NEED_DIALOG_VALUE,
  UNIT_TRANSLATE,
  USED_DATA_KEY
} from '../utils/HotspotUtils';

const TAG: string = 'HotspotShareController';
const BAND_ARRAY_DUAL: ResourceStr[] = [
  $r('app.string.hotspot_band_2_4'),
  $r('app.string.hotspot_band_5'),
];
const BAND_ARRAY_SINGLE: ResourceStr[] = [
  $r('app.string.hotspot_band_2_4'),
];
const LIMIT_ONCE: string = 'limit_once';
const SHEET_HEIGHT: number = 520;
const USED_DATA_DEFAULT: string = '0';
const USED_DATA_LENGTH: number = 2;

export class HotspotShareController implements ComponentControl {
  private dataSource?: DynamicDataSource;
  private compId?: string = ''
  private needNotice: boolean = false;
  // 当前已使用热点流量数据，以Byte为单位
  private currentUsedData: string = USED_DATA_DEFAULT;
  // 当前用户设置流量阈值，以Mb为单位
  private currentLimitData: string = USER_DATA_NO_LIMIT.toString();
  private dataHelper?: dataShare.DataShareHelper;

  init(compParam: CompCtrlParam): void {
    if (!compParam) {
      LogUtil.warn(`${TAG} init error: no compParam`);
      return;
    }
    LogUtil.info(`${TAG} init compId: ${compParam.compId}`);
    HotspotLimitDataManager.getInstance().initData();
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    this.initSettingData();
    this.registerSettingDataChange();
    let items: SettingItemModel[] = this.createItems();
    this.dataSource?.pushData(...items);
    this.refreshDetail();
  }

  destroy(): void {
    LogUtil.warn(`${TAG} destroy`);
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper, USED_DATA_KEY);
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper, DATA_LIMIT_KEY);
    this.dataHelper?.close();
  }

  private initSettingData(): void {
    this.needNotice = SettingsDataUtils.getSettingsData(NEED_DIALOG_KEY, NEED_DIALOG_VALUE) === NEED_DIALOG_VALUE;
    this.currentUsedData = SettingsDataUtils.getSecureValue(USED_DATA_KEY, USED_DATA_DEFAULT);
    this.currentLimitData = SettingsDataUtils.getSecureValue(DATA_LIMIT_KEY, USER_DATA_NO_LIMIT.toString());
  }

  private registerSettingDataChange(): void {
    let dataHelper = SettingsDataUtils
      .createDataHelper(NavEntryKey.HOTSPOT_SHARE_ENTRY) as Promise<dataShare.DataShareHelper>;
    dataHelper.then((dataHelper) => {
      this.dataHelper = dataHelper;
      SettingsDataUtils.registerSecurityDataChange(dataHelper,
        USED_DATA_KEY, () => {
          let usedData: string = SettingsDataUtils.getSecureValue(USED_DATA_KEY, USED_DATA_DEFAULT);
          LogUtil.info(`${TAG} SettingsData change:used mobile data: ${usedData}`);
          this.currentUsedData = usedData;
          this.refreshSubtitle(usedData);
        });
      SettingsDataUtils.registerSecurityDataChange(dataHelper,
        DATA_LIMIT_KEY, () => {
          let limitData: string = SettingsDataUtils.getSecureValue(DATA_LIMIT_KEY, USER_DATA_NO_LIMIT.toString());
          LogUtil.info(`${TAG} SettingsData change:current limit data: ${limitData}`);
          this.currentLimitData = limitData;
        });
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} createDataHelper error: code:${err?.code} message:${err?.message}`);
    });
  }

  private createItems(): SettingItemModel[] {
    let config: wifiManager.HotspotConfig | null = HotSpotUtils.getHotspotConfig();
    let defaultApBand: number = 0;
    if (config && config.band) {
      defaultApBand = config.band === 1 ? 0 : 1;
    }
    let hotspotLimit: string = HotspotLimitDataManager.getInstance().getCurLimitString();
    let items: ResourceStr[] = this.createApBandMenu();
    return [
      {
        id: LIMIT_ONCE,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.once_limit') },
        desc: { content: this.getSubtitle(this.currentUsedData) },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_CUSTOM,
          onItemClick: () => {
            LogUtil.info(`${TAG} onItemClick compId: ${this.compId}`);
            HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysHotspotEventGroup.HOTSPOT_LIMIT_CLICK);
            if (this.needNotice) {
              this.openDialog();
            } else {
              this.openModal();
            }
          },
          destination: URL_HOTSPOT_LIMIT_SHEET_PAGE,
          icon: $r('sys.symbol.chevron_right'),
          isSymbolIcon: true,
          sheetOptions: {
            onWillAppear: () => {
              LogUtil.info(`${TAG} sheet page onWillAppear`)
            },
            detents: [SHEET_HEIGHT],
          }
        },
        result: {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: hotspotLimit }
        }
      },
      {
        id: 'UpdateApBand',
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.hotspot_ap_band') },
        enabled: !SatelliteUtils.isCommunicationOpen(),
        detail: {
          type: ItemDetailType.DETAIL_TYPE_MENU,
          icon: $r('app.media.ic_arrow_down_new'),
          style: {
            width: $r('app.float.length_24'),
            height: $r('app.float.height_24'),
            fillColor: $r('sys.color.icon_tertiary'),
          },
          menu: {
            items: items,
            selectIcon: $r('app.media.ic_selected_ok'),
            onSelected: (index) => {
              LogUtil.info(`${TAG} onSelected ap band: ${index}`);
              if (index >= items.length) {
                return;
              }

              let config: wifiManager.HotspotConfig = HotSpotUtils.getHotspotConfig() as wifiManager.HotspotConfig;
              if (!config) {
                LogUtil.error(`${TAG} set ap band fail, config is empty.`);
                return;
              }

              config.band = index === 0 ? ApBand.AP_BAND_2_4 : ApBand.AP_BAND_5;
              HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysUpdateAPBANDEventGroup.UPDATE_AP_BAND,
                `${config.band}`);
              if (HotSpotUtils.isHotspotActive()) {
                HotSpotUtils.disableHotspot();
                HotSpotUtils.setHotspotConfig(config);
                HotSpotUtils.enableHotspot();
              } else {
                HotSpotUtils.setHotspotConfig(config);
              }
            },
            defaultFocus: defaultApBand,
          }
        },
        result: {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: HotSpotUtils.getApBandResourceStr(defaultApBand === 0 ? ApBand.AP_BAND_2_4 : ApBand.AP_BAND_5),
            style: {
              fontColor: $r('sys.color.font_secondary'),
              fontSize: $r('sys.float.Body_M')
            }
          }
        }
      }
    ]
  }
  private createApBandMenu(): ResourceStr[] {
    let isDualBand: boolean = HotSpotUtils.isSupportDualApBand();
    LogUtil.info(`${TAG} createApBandMenu isDualBand: ${isDualBand}`)
    if (isDualBand) {
      return BAND_ARRAY_DUAL;
    }
    return BAND_ARRAY_SINGLE;
  }

  private openDialog(): void {
    this.needNotice = false;
    SettingsDataUtils.setSettingsData(NEED_DIALOG_KEY, NO_NEED_DIALOG_VALUE);
    notifyCompStateChange(this.compId + '.' + LIMIT_ONCE, new Map<SettingStateType, SettingBaseState>([
      [SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        title: $r('app.string.once_limit'),
        message: ResourceUtil.getNumberFormatStringSync($r('app.string.data_limit_notice'), '0'),
        buttons: [
          {
            value: $r('app.string.dialog_know'),
            action: (item: SettingItemModel) => {
              this.openModal();
            }
          }
        ]
      } as SettingDialogState]
    ]))
  }

  private openModal(): void {
    notifyCompStateChange(this.compId + '.' + LIMIT_ONCE, new Map<SettingStateType, SettingBaseState>([
      [SettingStateType.STATE_TYPE_ITEM_SHEET, {
        state: true,
        sheetDetents: [SHEET_HEIGHT],
        sheetHeight: SheetSize.FIT_CONTENT,
        keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
      } as SettingModalState]
    ]))
  }

  private refreshDetail(): void {
    let limitStr: string = HotspotLimitDataManager.getInstance().getCurLimitString();
    notifyCompStateChange(this.compId + '.' + LIMIT_ONCE, new Map<SettingStateType, SettingBaseState>([
      [SettingStateType.STATE_TYPE_ITEM_RESULT, {
        content: limitStr
      } as SettingTextState]
    ]));
  }

  private refreshSubtitle(usedData: string): void {
    notifyCompStateChange(this.compId + '.' + LIMIT_ONCE, new Map<SettingStateType, SettingBaseState>([
      [SettingStateType.STATE_TYPE_ITEM_DESP, {
        content: this.getSubtitle(usedData)
      } as SettingTextState]
    ]));
  }

  private getSubtitle(usedByte: string): ResourceStr {
    if (this.hasDataLimitReached(parseInt(usedByte)) && !HotSpotUtils.isHotspotActive()) {
      return $r('app.string.data_reach_limit');
    }
    let covertedData: string = HotSpotUtils.convertByteUnit(usedByte);
    let subStrs: string[] = covertedData.split(' ');
    if (subStrs.length !== USED_DATA_LENGTH) {
      LogUtil.warn(`${TAG} usedByte string is illegal`);
      return '';
    }
    let num: string = subStrs[0];
    let unit: string = subStrs[1];
    LogUtil.info(`${TAG} current used data: ${num} ${unit}`);
    let unitTran: string = UNIT_TRANSLATE.get(unit) as string;
    let systemLanguage: string = i18n.System.getSystemLocale();
    let uintFormat: intl.NumberFormat = new intl.NumberFormat(systemLanguage, {style: 'unit', unit: unitTran,
      unitDisplay: 'narrow'});
    let formattedNumber: string = uintFormat.format(Number(num));
    return ResourceUtil.getFormatStringSync($r('app.string.used_mobile_data'), formattedNumber);
  }

  private hasDataLimitReached(usedBytes: number): boolean {
    let curLimitNum: number = parseInt(this.currentLimitData);
    if (Number.isNaN(curLimitNum) || curLimitNum < 0) {
      return false;
    }
    let limitBytes: number = HotSpotUtils.convertMb2Byte(parseInt(this.currentLimitData));
    return usedBytes >= limitBytes;
  }
}