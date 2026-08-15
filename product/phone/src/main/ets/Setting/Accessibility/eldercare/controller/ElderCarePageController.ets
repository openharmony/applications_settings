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

import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ElderCareManager, ElderCareUtils } from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysElderCareEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PageUrl } from '../../../../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'ElderCarePageController : ';

/**
 * 关怀模式-page页-controller
 *
 * @since 2024-11-02
 */
export class ElderCarePageController implements ComponentControl {
  private initialLevel: string = '';
  private adjustedLevel: string = '';

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysElderCareEventGroup.ELDER_CARE_ENTER, 'pageUrl: ' + PageUrl.ACCESSIBILITY_ELDER_CARE_PAGE_URL);
    this.initialLevel = SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_PRE_SET_LEVEL, '0');
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
  }

  updateConfig(): void {
    // 若用户没修改过档位，则字体大小、粗细、图标都不做修改
    let isChangedPre = SettingsDataUtils.getSettingsData(ElderCareUtils.ELDER_CARE_PRE_HAS_CHANGED, 'false') === 'true';
    if (!isChangedPre) {
      return;
    }
    let targetElderCareLevel = Number(SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_PRE_SET_LEVEL,
      ElderCareUtils.SWITCH_OFF));
    let targetFontSize = ElderCareUtils.FONT_SIZE_SCALE_LIST[targetElderCareLevel];
    let targetFontWeight = ElderCareUtils.FONT_WEIGHT_SCALE_LIST[targetElderCareLevel];
    let targetScbIconSize = ElderCareUtils.SCB_ICON_SIZE_LIST[targetElderCareLevel];

    ElderCareManager.setFontSize(targetFontSize);
    ElderCareManager.setFontWeight(targetFontWeight);
    LogUtil.info(`${TAG} set targetFontSize：${targetFontSize}, targetFontWeight: ${targetFontWeight},
      desktopIconChangeSize: ${targetScbIconSize}, targetElderCareLevel: ${targetElderCareLevel}`);
    // 修改桌面图标大小
    ElderCareUtils.setSecureValue(ElderCareUtils.DESKTOP_ICON_CHANGE_SIZE, targetScbIconSize.toString(),
      getContext(this));
    SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, targetElderCareLevel.toString());
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    let fontScalePre = Number(SettingsDataUtils.getSecureValue('elder_care_font_scale_pre', ElderCareUtils.SWITCH_OFF));
    ElderCareUtils.ELDER_CARE_START_PRE = fontScalePre;
    if (ElderCareUtils.isElderCareOn()) {
      SettingsDataUtils.setSettingsData(ElderCareUtils.ELDER_CARE_PRE_HAS_CHANGED, 'false');
    }
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    if (ElderCareUtils.isElderCareOn()) {
      this.updateConfig();
      this.adjustedLevel = SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_PRE_SET_LEVEL, '0');
      const param: Record<string, Object> = {};
      param.INITIAL_ENLARGE_DISPLAY_LEVEL = this.initialLevel;
      param.ADJUSTED_ENLARGE_DISPLAY_LEVEL = this.adjustedLevel;
      HiSysEventUtil.reportBehaviorEventByUE(HiSysElderCareEventGroup.ELDER_CARE_UPDATE_ENLARGE_LEVEL, param);
    }
  }
}
