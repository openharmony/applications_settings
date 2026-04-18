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
import settings from '@ohos.settings';
import dataShare from '@ohos.data.dataShare';
import call from '@ohos.telephony.call';
import { BusinessError } from '@ohos.base';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { ArrayUtil } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/util/ArrayUtil';
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ContactListItem, ContactPolicy, ContactsColumns, SpecifiedBean } from '../model/IncomingCallParam';
import { FOCUS_MODE_CALL_MESSAGE_POLICY } from '../controller/ContactPolicyRadioController';

const TAG: string = 'IncomingCallUtils:';
const CONST_AUDIO_SHOW_STEREO_ENHANCEMENT_SWITCH = 'const.multimedia.audio.show_stereo_enhancement_switch';
const CONST_AUDIO_AI_VOICE_NOISE_SUPPRESSION_SUPPORTED = 'const.multimedia.audio.ai_voice_noise_suppression_supported';

export class IncomingCallUtils {
  private static instance: IncomingCallUtils;
  private dataShareHelper?: Promise<dataShare.DataShareHelper> | dataShare.DataShareHelper;
  private static isVoiceCapabilityEnable: boolean = call.hasVoiceCapability();

  public static getInstance(): IncomingCallUtils {
    if (IncomingCallUtils.instance) {
      return IncomingCallUtils.instance;
    }
    IncomingCallUtils.instance = new IncomingCallUtils();
    return IncomingCallUtils.instance;
  }

  public async getDataAbilityHelper() {
    if (this.dataShareHelper == undefined) {
      this.dataShareHelper = await dataShare.createDataShareHelper(
        GlobalContext.getInstance().get('CallingContext') as Context, ContactsColumns.CONTENT_URI, {});
    }
    return this.dataShareHelper;
  }

  async getSelectContactList(callBack: Function) {
    LogUtil.info(`${TAG} updateContactNumber start`);
    this.findAllSelectContacts((focusModeList) => {
      if (ArrayUtil.isEmpty(focusModeList)) {
        let emptyResult: SpecifiedBean[] = [];
        callBack(emptyResult);
        return;
      }
      LogUtil.info(`${TAG} updateContactNumber success`);
      callBack(focusModeList);
    });
    LogUtil.info(`${TAG} updateContactNumber end`);
  }

  findAllSelectContacts(callback: (v: ContactListItem[]) => void) {
    LogUtil.info(`${TAG} findAllSelectContacts`);
    let conditionArgs = new dataSharePredicates.DataSharePredicates();
    conditionArgs.equalTo(ContactsColumns.IS_DELETED, '0');
    conditionArgs.and();
    conditionArgs.equalTo(ContactsColumns.FOCUS_MODE_LIST, '1');
    conditionArgs.and();
    conditionArgs.orderByAsc(ContactsColumns.SORT).orderByAsc(ContactsColumns.SORT_KEY);
    this.getDataAbilityHelper().then((dataAbilityHelper: dataShare.DataShareHelper) => {
      dataAbilityHelper.query(ContactsColumns.CONTACT_URI, conditionArgs, ContactListItem.COLUMNS)
        .then((resultSet: DataShareResultSet) => {
          let rst: ContactListItem[] = [];
          if (resultSet.rowCount === 0) {
            resultSet.close();
            callback(rst);
          } else {
            resultSet.goToFirstRow();
            do {
              rst.push(new ContactListItem(resultSet));
            } while (resultSet.goToNextRow());
            resultSet.close();
            LogUtil.info(`${TAG} findAllSelectContacts query data success.`);
            callback(rst);
          }
        })
        .catch((error: BusinessError) => {
          LogUtil.error(`${TAG} findAllSelectContacts error: ${error?.message}`);
          callback([]);
        });
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} findAllSelectContacts error: ${error?.message}`);
      callback([]);
    });
  }

  dealSelectContactsData(data: SpecifiedBean): Array<SpecifiedBean> {
    let selectContacts: SpecifiedBean[] = []
    let contacts: string = JSON.stringify(data);
    let contactsList: SpecifiedBean[] = [];
    contactsList = JSON.parse(contacts);
    contactsList.forEach((contacts) => {
      selectContacts.push(contacts);
    })
    return selectContacts;
  }

  public static isVoiceCapabilityDisable(): boolean {
    return !IncomingCallUtils.isVoiceCapabilityEnable;
  }

  /**
   * 校验手机是否支持智能通话降噪
   */
  static isSupportAiVoice(): boolean {
    try {
      const isSupportAiVoice = systemParameterEnhance.getSync(CONST_AUDIO_AI_VOICE_NOISE_SUPPRESSION_SUPPORTED, 'true');
      LogUtil.showInfo(TAG, `isSupportAiVoice: ${isSupportAiVoice}`);
      return isSupportAiVoice === 'true';
    } catch (err) {
      LogUtil.showError(TAG, `showToast error ${err?.code}`);
      return false;
    }
  }

  /**
   * 校验产品是否支持立体声增强
   */
  static isSupportStereoEnhancement(): boolean {
    try {
      const isSupportStereoEnhancement = systemParameterEnhance.getSync(CONST_AUDIO_SHOW_STEREO_ENHANCEMENT_SWITCH, 'true');
      LogUtil.showInfo(TAG, `isSupportStereoEnhancement: ${isSupportStereoEnhancement}`);
      return isSupportStereoEnhancement === 'true';
    } catch (err) {
      LogUtil.showError(TAG, `showToast error ${err?.code}, message: ${err?.message}`);
      return false;
    }
  }

  public setMenuTitle(contactPolicy: string): string {
    let menuTitle = '';
    switch (contactPolicy) {
      case ContactPolicy.ALLOW_EVERYONE:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_everyone'));
        break;
      case ContactPolicy.ALLOW_EXISTING_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_only_existing_contacts'));
        break;
      case ContactPolicy.ALLOW_FAVORITE_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_only_favorite_contacts'));
        break;
      case ContactPolicy.ALLOW_SPECIFIED_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_only_specified_contacts'));
        break;
      default:
        menuTitle = ResourceUtil.getStringSync($r('app.string.forbid_everyone'));
        break;
    }
    return menuTitle;
  }

  public isShowRepeatCall(): boolean {
    let contactPolicy = SettingsDataUtils.getSettingsData(FOCUS_MODE_CALL_MESSAGE_POLICY,
      ContactPolicy.FORBID_EVERYONE, settings.domainName.USER_PROPERTY);
    return contactPolicy != ContactPolicy.ALLOW_EVERYONE;
  }
}