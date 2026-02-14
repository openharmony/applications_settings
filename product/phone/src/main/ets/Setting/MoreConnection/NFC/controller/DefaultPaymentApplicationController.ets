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
import { bundleManager } from '@kit.AbilityKit';
import { cardEmulation } from '@kit.ConnectivityKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { BrowserListPro } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import {
  ComparableSettingItemModel,
  ItemResultType,
  ItemType,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { NFCTool } from '../util/NFCTool';

const TAG: string = 'DefaultPaymentApplicationController : ';
const DEFAULT_PAY_APP = 'nfc_payment_default_app';
const DEFAULT_PAYMENT_APPLICATION_ITEM: string =
  'Setting.nfc_settings.default_payment_application_group.default_payment_application_item';
const SIM_CARD_BUNDLE_NAME: string = 'com.ohos.simtoolkits';

export class DefaultPaymentApplicationController implements ComponentControl {
  private dataSource?: OrderedDataSource;

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.dataSource = compParam.dataSource as OrderedDataSource;
    this.getDefaultNfc();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
  }

  /**
   * 获取NFC默认付款应用列表
   */
  public async getNfcList(): Promise<BrowserListPro[]> {
    let nfcListPro: BrowserListPro[] = [];
    let nfcList: bundleManager.AbilityInfo[] = [];
    try {
      nfcList = cardEmulation.getPaymentServices();
    } catch (error) {
      LogUtil.error(`${TAG} getPaymentServices catch error, message:${error?.message}`);
    }
    nfcList.forEach((nfcListItem: bundleManager.AbilityInfo, index) => {
      LogUtil.info(`${TAG} nfcListItem name:${nfcListItem.name} bundleName:${nfcListItem.bundleName}`);
      try {
        const resourceManager = ResourceManagerUtil.getBundleResourceManager(nfcListItem?.bundleName);
        if (!resourceManager) {
          LogUtil.info(`${TAG} resourceManager is null`);
          return;
        }

        const iconDescriptor: DrawableDescriptor = resourceManager.getDrawableDescriptor(nfcListItem?.iconId, 0, 1);
        if (!iconDescriptor) {
          LogUtil.warn(`${TAG} nfc list icon load fail, icon descriptor is undefined`);
        }
        nfcListPro.push({
          labelId: nfcListItem?.labelId as number,
          label: resourceManager.getStringValue(nfcListItem?.labelId),
          icon: iconDescriptor?.getPixelMap(),
          bundleName: nfcListItem?.bundleName,
          name: nfcListItem?.name,
        });
        MemoryMgrUtils.removeNapiWrap(resourceManager, false);
      } catch (error) {
        LogUtil.error(`${TAG} push nfcListItem catch error, message:${error?.message}`);
      }
    });
    LogUtil.info(`${TAG} nfclistPro.length:${nfcListPro.length}`);
    return nfcListPro;
  }

  private getSummary(bundleName: string): ResourceStr {
    if (bundleName === SIM_CARD_BUNDLE_NAME) {
      return ResourceUtil.getNumberFormatStringSync($r('app.string.nfc_payment_sim_summary'),
        LanguageUtils.getNumberFormat(1));
    }
    return '';
  }

  /**
   * 默认付款应用为空, 刷新结果为未设置
   */
  private isDefaultNfcValid(nfcList: BrowserListPro[]): boolean {
    if (nfcList.length !== 0) {
      return true;
    }
    notifyCompStateChange(DEFAULT_PAYMENT_APPLICATION_ITEM,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: $r('app.string.not_set'),
          }
        } as SettingResultState]]));
    return false;
  }

  /**
   * 动态加载NFC默认付款应用
   */
  private async getDefaultNfc(): Promise<void> {
    this.getNfcList().then((nfcList) => {
      if (!this.isDefaultNfcValid(nfcList)) {
        return;
      }
      let curDefaultPayAPPValue: string = SettingsDataUtils.getSettingsData(DEFAULT_PAY_APP, '')
      Promise.all(nfcList.map(nfc => nfc.label)).then((values) => {
        if (!values.length) {
          return;
        }
        values.forEach((item, index) => {
          let value = `${nfcList[index].bundleName}/${nfcList[index].name}`;
          let summary: ResourceStr = this.getSummary(nfcList[index].bundleName ?? '');
          let settingItem: ComparableSettingItemModel = {
            type: ItemType.ITEM_TYPE_STANDARD,
            id: `nfc_list_${nfcList[index].bundleName}_${nfcList[index].labelId}`,
            icon: {
              icon: nfcList[index].icon as PixelMap | ResourceStr,
              iconType: SettingIconType.ICON_TYPE_APPICON,
            },
            title: ({ content: item as ResourceStr }),
            desc: { content: summary },
            result: {
              type: ItemResultType.RESULT_TYPE_RADIO,
              result: {
                checked: curDefaultPayAPPValue === value,
                style: {
                  width: 22,
                  height: 22,
                  showUnchecked: false,
                },
                onCheck: (isCheck: boolean, item: SettingItemModel) => {
                  if (isCheck) {
                    NFCTool.notifyRefreshDefaultApp(value, DEFAULT_PAYMENT_APPLICATION_ITEM);
                  }
                }
              },
            },
          }
          if (this.dataSource) {
            this.dataSource.pushData(settingItem);
          }
        })
      });
    });
  }
}