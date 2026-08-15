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

import { configPolicy } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import { HashMap } from '@kit.ArkTS';
import { curves } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import {
  ApplicationUtil,
  CODE_RECOVERY_SUCCESS,
  CODE_RECOVERY_CANCELED
} from '@ohos/settings.common/src/main/ets/utils/ApplicationUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { CardInfo, SuggestionConfig } from '../model/SuggestionConfig';
import { SuggestionInfo } from '../model/SuggestionInfo';
import { SuggestionCardManager } from '../manager/SuggestionCardManager';
import { SuggestionAccessorConfig } from '../constant/SuggestionAccessorConfig';
/* instrument ignore file */
export const SINGLE_SUGGESTION = 1;

export const SUGGESTION_EFFECT: TransitionEffect = TransitionEffect.asymmetric(TransitionEffect.OPACITY.animation({
  delay: 10,
  curve: curves.interpolatingSpring(0, 1, 180, 27)
}).combine(TransitionEffect.scale({ x: 0.9, y: 0.9 })),
  TransitionEffect.OPACITY.animation({ curve: curves.interpolatingSpring(0, 1, 180, 27) })
    .combine(TransitionEffect.scale({ x: 0.9, y: 0.9 }))
)

// 默认连续显示时间
const DEFAULT_LONGEST_CONTINUOUS_SHOW_TIME: number = DateTimeUtil.getPerHourInMillis() * 72;

// 显示判断默认最小时间间隔
const DEFAULT_SILENT_TIME_INTERVAL: number = DateTimeUtil.getPerDayInMillis();

const SUGGESTION_CARD_PREFERENCE_NAME: string = 'suggestion_config'

const PREFIX_SUGGESTION_SHOW_TIME = 'suggestion_show_';

const PREFIX_SUGGESTION_HIDE_TIME = 'suggestion_hide_';

const LAST_SHOW_SUGGESTION_CARD = 'suggestion_last_show_card';

const TAG: string = 'SuggestionUtil';

const CCM_SUGGESTION_CONFIG = 'etc/settings/setting_homepage_suggestion.json';

const MAX_ICON_SIZE: number = 512 * 512;

export class SuggestionUtil {
  private longestShowTime: number | undefined = 0;
  private silentTimeInterval: number | undefined = 0;
  private suggestionConfig?: SuggestionConfig = undefined;
  private supportedCardMap: HashMap<string, number> = new HashMap<string, number>();

  /**
   * 加载推荐卡片配置信息
   */
  private async loadSuggestionConfig(): Promise<void> {
    LogUtil.info(`${TAG} loadSuggestionConfig`);
    if (!this.suggestionConfig) {
      let config: string = await this.getCcmSuggestionConfigStr();
      try {
        this.suggestionConfig = JSON.parse(config) as SuggestionConfig;
      } catch (err) {
        LogUtil.warn(`${TAG} parse suggestionConfig invalid ${err?.code}  ${err?.message}`);
      }
      this.silentTimeInterval = this.suggestionConfig?.silentTime ?? DEFAULT_SILENT_TIME_INTERVAL;
      this.longestShowTime = this.suggestionConfig?.longestShowTime ?? DEFAULT_LONGEST_CONTINUOUS_SHOW_TIME;
      LogUtil.info(`${TAG} parse suggestionConfig ${this.silentTimeInterval} ${this.longestShowTime}`);
      this.initSupportedMap();
    }
  }

  private initSupportedMap(): void {
    if (!this.suggestionConfig) {
      LogUtil.warn(`${TAG} suggestionConfig is invalid`);
      return;
    }
    let cardList = this.suggestionConfig.cardInfoList;
    LogUtil.info(`${TAG} parse suggestionConfig cardList ${JSON.stringify(cardList)}`);
    if (!cardList) {
      LogUtil.warn(`${TAG} cardList is invalid`);
      return;
    }
    let cardMap: HashMap<string, number> = new HashMap<string, number>();
    for (let i = 0; i < cardList.length; i++) {
      let cardInfo: CardInfo = cardList[i];
      if (!cardInfo || !cardInfo.bundleName || !cardInfo.cardName || cardInfo.priority === undefined) {
        LogUtil.warn(`${TAG} cardInfo is invalid`);
        continue;
      }
      let key: string = this.getCardKey(cardInfo);
      LogUtil.info(`${TAG} parse suggestionConfig get card priority ${key} ${cardInfo.priority}`);
      cardMap.set(key, cardInfo.priority);
    }
    this.supportedCardMap = cardMap;
  }

  private getCardKey(cardInfo: CardInfo): string {
    return cardInfo.bundleName + '_' + cardInfo.cardName;
  }

  public getCardKeyBySuggestion(suggestionInfo: SuggestionInfo): string {
    return suggestionInfo.bundleName + '_' + suggestionInfo.name;
  }

  public async getSupportedCardMap(): Promise<HashMap<string, number>> {
    LogUtil.info(`${TAG} getSupportedCardMap`);
    await this.loadSuggestionConfig();
    return this.supportedCardMap;
  }

  /**
   * 读取推荐项CCM配置
   *
   * @returns 推荐项ccm配置信息
   */
  private async getCcmSuggestionConfigStr(): Promise<string> {
    try {
      let filePath: string = await configPolicy.getOneCfgFile(CCM_SUGGESTION_CONFIG);
      let configStr: string = fs.readTextSync(filePath);
      if (configStr && configStr.trim().length > 0) {
        return configStr;
      }
    } catch (e) {
      LogUtil.error(`${TAG} getCcmPageConfigStr exception:${e?.code}  ${e?.message}`);
    }
    LogUtil.warn(`${TAG} use default suggestion CCM config`);
    return SuggestionAccessorConfig.getDefaultCcmConfigStr();
  }

  /**
   * 卡片是否需要展示
   *
   * @param suggestionInfo 卡片推荐项
   * @returns 是否需要展示
   */
  async isNeedShow(suggestionInfo: SuggestionInfo): Promise<boolean> {
    await this.loadSuggestionConfig();
    if (!this.suggestionConfig) {
      return false;
    }
    let suggestionShowKey: string = this.getSuggestionKey(suggestionInfo, PREFIX_SUGGESTION_SHOW_TIME);
    if (StringUtil.isEmpty(suggestionShowKey)) {
      LogUtil.warn(`${TAG}, suggestionShowKey is invalid`);
      return false;
    }
    let lastShowSuggestion: string = this.getLastShowCard();
    let currentTime: number = new Date().getTime();
    // 需要管控卡片最长显示时间时，此卡片和上次显示的卡片相同, 则不超过连续最长显示时间才能继续显示
    if (this.longestShowTime === undefined) {
      this.longestShowTime = DEFAULT_LONGEST_CONTINUOUS_SHOW_TIME;
    }
    if (this.silentTimeInterval === undefined) {
      this.silentTimeInterval = DEFAULT_SILENT_TIME_INTERVAL;
    }
    if (suggestionShowKey === lastShowSuggestion) {
      let lastShowTime: number = this.getIntValueFromPreference(suggestionShowKey);
      let cardShowTime:number  = currentTime - lastShowTime;
      // 卡片上一次显示时间在[最长显示时间, 最长显示时间+静默时间]区间内，则不显示
      if (cardShowTime >= this.longestShowTime && cardShowTime <= this.getLongestShowAddSilentTime()) {
        LogUtil.info(`${TAG}, last show time is in [longestShowTime,longestShowTime + silentTime], no need show`);
        return false;
      }
    }
    // 卡片被用户点击隐藏，则超过最小时间间隔（静默时间）再做显示
    let lastHideTime: number =
      this.getIntValueFromPreference(this.getSuggestionKey(suggestionInfo, PREFIX_SUGGESTION_HIDE_TIME));
    if (currentTime - lastHideTime < this.silentTimeInterval) {
      LogUtil.info(`${TAG}, last hide time < silentTime, no need show`);
      return false;
    }
    return true;
  }

  private getLongestShowAddSilentTime(): number {
    if (this.longestShowTime === undefined) {
      this.longestShowTime = DEFAULT_LONGEST_CONTINUOUS_SHOW_TIME;
    }
    if (this.silentTimeInterval === undefined) {
      this.silentTimeInterval = DEFAULT_SILENT_TIME_INTERVAL;
    }
    return this.longestShowTime + this.silentTimeInterval;
  }

  /**
   * 根据推荐卡片信息生成对应键值
   *
   * @param suggestionInfo 推荐卡片信息
   * @param prefix 前缀（区分显示卡片时间/隐藏卡片时间）
   * @returns 卡片键值
   */
  getSuggestionKey(suggestionInfo: SuggestionInfo, prefix: string = ''): string {
    if (suggestionInfo.bundleName && suggestionInfo.name && suggestionInfo.id) {
      return prefix + suggestionInfo.bundleName + '_' + suggestionInfo.name + '_' + suggestionInfo.id;
    }
    return '';
  }

  /**
   * 从preference获取卡片对应的时间
   *
   * @param key 卡片键值
   * @returns 显示时间
   */
  getIntValueFromPreference(key: string): number {
    if (StringUtil.isEmpty(key)) {
      return 0;
    }
    let value = PreferencesUtil.getSyncWithPreferenceName(key, 0 as number, SUGGESTION_CARD_PREFERENCE_NAME);
    LogUtil.info(`${TAG}, last time is ${value}`);
    return parseInt(value.toString());
  }

  /**
   * 获取上次显示的卡片
   *
   * @returns 上次显示的卡片
   */
  private getLastShowCard(): string {
    let value = PreferencesUtil.getSyncWithPreferenceName(LAST_SHOW_SUGGESTION_CARD, 0 as number,
      SUGGESTION_CARD_PREFERENCE_NAME);
    LogUtil.info(`${TAG}, last show time is ${value}`);
    return value.toString();
  }

  /**
   * 设置首页推荐项显示时间
   *
   * @param suggestionInfo 首页推荐项信息
   */
  public setSuggestionShowTime(suggestionInfo: SuggestionInfo): void {
    let suggestionShowKey: string = this.getSuggestionKey(suggestionInfo, PREFIX_SUGGESTION_SHOW_TIME);
    let lastShowSuggestion: string = this.getLastShowCard();
    let lastShowTime: number = this.getIntValueFromPreference(lastShowSuggestion);
    let cardShowTime  = new Date().getTime() - lastShowTime;
    // 卡片显示时间超过最长显示时间+静默时间后，再次显示需要刷新统计时间
    if (suggestionShowKey === lastShowSuggestion && cardShowTime <= this.getLongestShowAddSilentTime()) {
      return;
    }
    PreferencesUtil.putValueWithPreferenceName(LAST_SHOW_SUGGESTION_CARD, suggestionShowKey,
      SUGGESTION_CARD_PREFERENCE_NAME);
    PreferencesUtil.putValueWithPreferenceName(suggestionShowKey, new Date().getTime(),
      SUGGESTION_CARD_PREFERENCE_NAME);
  }

  /**
   * 设置首页推荐项隐藏时间
   *
   * @param suggestionInfo 首页推荐项信息
   */
  public setSuggestionSilent(suggestionInfo: SuggestionInfo): void {
    let suggestionHideKey: string = this.getSuggestionKey(suggestionInfo, PREFIX_SUGGESTION_HIDE_TIME);
    PreferencesUtil.putValueWithPreferenceName(suggestionHideKey, new Date().getTime(),
      SUGGESTION_CARD_PREFERENCE_NAME);

    // 推荐项隐藏后重置上次显示时间
    let suggestionShowKey: string = this.getSuggestionKey(suggestionInfo, PREFIX_SUGGESTION_SHOW_TIME);
    PreferencesUtil.putValueWithPreferenceName(suggestionShowKey, 0,
      SUGGESTION_CARD_PREFERENCE_NAME);
  }

  /**
   * 根据图标名称跨进程获取图标资源
   *
   * @param name 图标名称
   * @param resourceManager 目标进程的资源管理器
   * @returns 图片
   */
  public getIconByName(name: string, resourceManager: resourceManager.ResourceManager): PixelMap | undefined {
    if (!resourceManager || !name) {
      return undefined;
    }
    try {
      let icon: Uint8Array = resourceManager.getMediaByNameSync(name);
      if (icon?.byteLength > MAX_ICON_SIZE) {
        return undefined;
      }
      let imageSource: image.ImageSource = image.createImageSource(icon?.buffer);
      return imageSource.createPixelMapSync();
    } catch (err) {
      LogUtil.warn(`${TAG} getIconByName failed ${err.msg}`);
    }
    return undefined;
  }

  /**
   * 根据图标名称跨进程获取图标资源
   *
   * @param id 图标id
   * @param resourceManager 目标进程的资源管理器
   * @returns 图片
   */
  public getIconById(id: string, resourceManager: resourceManager.ResourceManager): PixelMap | undefined {
    if (!resourceManager || !id) {
      return undefined;
    }
    try {
      let icon: Uint8Array = resourceManager.getMediaContentSync(parseInt(id));
      if (icon?.byteLength > MAX_ICON_SIZE) {
        return undefined;
      }
      let imageSource: image.ImageSource = image.createImageSource(icon?.buffer);
      return imageSource.createPixelMapSync();
    } catch (err) {
      LogUtil.warn(`${TAG} getIconById failed ${err.msg}`);
    }
    return undefined;
  }

  /**
   * 根据资源id跨进程获取字串
   *
   * @param name 资源name
   * @param resourceManager 目标进程的资源管理器
   * @returns 对应字串
   */
  getStringByResourceManager(name: string, resourceManager: resourceManager.ResourceManager): undefined | string {
    if (!resourceManager || !name) {
      return undefined;
    }
    try {
      return resourceManager?.getStringByNameSync(name);
    } catch (err) {
      LogUtil.warn(`${TAG} getString failed`);
    }
    return undefined;
  }

  public async jumpToSuggestionDetailPage(suggestionInfo: SuggestionInfo,
    isFromHomePage: boolean = false): Promise<void> {
    LogUtil.info(`${TAG} jumpToSuggestionDetailPage ${suggestionInfo.routerUri} ${suggestionInfo.jumpBundleName}
    ${suggestionInfo.abilityName}`);
    if (!suggestionInfo.routerUri) {
      return;
    }
    if (isFromHomePage) {
      let pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
      const array: string[] | undefined = pathInfoStack?.getAllPathName();
      if (array?.length === 1 && array[0] === suggestionInfo.routerUri) {
        LogUtil.info(`${TAG} is same page, no need jump`);
        return;
      }
    }
    let pushParam = new PushParam(suggestionInfo.actionParams);
    // 外部UIExtension界面
    if (suggestionInfo.routerUri === NavEntryKey.COMMON_PAGE) {
      if (!suggestionInfo.jumpBundleName || !suggestionInfo.abilityName) {
        return;
      }
      let resultCode: number =
        ApplicationUtil.isApplicationAvailable(suggestionInfo.jumpBundleName) ? CODE_RECOVERY_SUCCESS :
          await ApplicationUtil.requestRecoveryApplication(suggestionInfo.jumpBundleName);
      if (resultCode === CODE_RECOVERY_SUCCESS) {
        pushParam.bundleName = suggestionInfo.jumpBundleName;
        pushParam.abilityName = suggestionInfo.abilityName;
        PageRouter.push(NavEntryKey.COMMON_PAGE, pushParam);
      } else if (resultCode === CODE_RECOVERY_CANCELED) {
        LogUtil.showWarn(TAG, `cancel recover application ${suggestionInfo.jumpBundleName}, refresh page`);
        SuggestionCardManager.getInstance().refreshData(getContext());
      } else {
        LogUtil.showError(TAG,
          `failed to start page for ${suggestionInfo.jumpBundleName} : ${suggestionInfo.abilityName}`);
      }
      return;
    }
    // 设置内部配置了entry-key的界面
    PageRouter.push(suggestionInfo.routerUri, pushParam, false, undefined, !isFromHomePage);
  }

  public isSameSuggestion(firstSuggestion: SuggestionInfo, nextSuggestion: SuggestionInfo): boolean {
    let firstKey:string = this.getSuggestionKey(firstSuggestion);
    let nextKey:string = this.getSuggestionKey(nextSuggestion);
    return firstKey === nextKey;
  }

  public getBadgeValue(badgeNumber:number):string {
    if (badgeNumber > 99) {
      return '99+';
    }
    return badgeNumber > SINGLE_SUGGESTION ? badgeNumber.toString() : ''
  }
}

export enum SuggestionOperation {
  SHOW = 0,
  CLOSE = 1,
  CLICK_SINGLE = 2,
  JUMP_MORE = 3
}

export default new SuggestionUtil;