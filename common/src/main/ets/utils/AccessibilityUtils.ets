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

import accessibility from '@ohos.accessibility';
import { LogUtil } from './LogUtil';
import { ResourceUtil } from './ResourceUtil';

const TAG: string = 'AccessibilityUtils : ';

/**
 * 无障碍的默认描述值 单指双击即可执行
 */
export const TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS: string = '';

/**
 * 无障碍的无描述值
 */
export const TALKBACK_NOT_SUPPORT_DEFAULT_CLICK_TIPS: string = ' ';

/**
 * Accessibility工具类
 *
 * @since 2024-07-08
 */
export class AccessibilityUtils {
  /**
   * 判断当前是否在无障碍模式下
   */
  public static isAccessibilityMode(): boolean {
    const isOpenAccessibility: boolean = accessibility.isOpenAccessibilitySync();
    const isOpenTouchGuide: boolean = accessibility.isOpenTouchGuideSync();
    return isOpenAccessibility && isOpenTouchGuide;
  }

  /**
   * 在无障碍模式主动聚焦
   *
   * @param bundleName 主动播报信息
   *
   */
  public static requestFocusAccessibility(customId: string): void {
    AccessibilityUtils.requestFocusAccessibilityWithBundleName(customId, 'com.ohos.sceneboard');
  }

  /**
   * 无障碍模式主动聚焦
   *
   * @param customId 组件id
   * @param bundleName 不传则默认设置包名
   */
  public static requestFocusAccessibilityWithBundleName(customId: string, bundleName?: string): void {
    if (!AccessibilityUtils.isAccessibilityMode()) {
      return;
    }
    let eventInfo: accessibility.EventInfo = ({
      type: 'requestFocusForAccessibility',
      bundleName: bundleName ?? 'com.ohos.settings',
      triggerAction: 'common',
      customId,
    });

    try {
      accessibility.sendAccessibilityEvent(eventInfo, (err) => {
        /* instrument ignore if*/
        if (err) {
          LogUtil.error(`${TAG} sendAccessibilityEvent is failed, code:${err?.code} message:${err?.message}`);
          return;
        }
        LogUtil.info(`${TAG} sendAccessibilityEvent is Succeeded, customId:${customId}`);
      });
    } catch (error) {
      LogUtil.error(`${TAG} sendAccessibilityEvent catch failed, code:${error?.code} message:${error?.message}`);
    }
  }

  /**
   * 无障碍模式下主动播报内容，如Radio选中后播报"已选中"
   *
   * @param text 播报内容资源字符串
   */
  public static announceText(text: ResourceStr): void {
    LogUtil.debug(`${TAG} announceText`);
    if (!AccessibilityUtils.isAccessibilityMode()) {
      return;
    }
    let eventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.settings',
      triggerAction: 'common',
      textAnnouncedForAccessibility: ResourceUtil.getStringSync(text)
    });
    accessibility.sendAccessibilityEvent(eventInfo).then(() => {
      LogUtil.debug(`${TAG} announceText success`);
    });
  }

  /**
   * 无障碍模式下不打断主动播报内容，如Radio选中后播报"已选中"
   *
   * @param text 播报内容资源字符串
   */
  public static announceTextNoInterrupt(text: ResourceStr): void {
    LogUtil.debug(`${TAG} announceTextNoInterrupt`);
    /* instrument ignore if*/
    if (!AccessibilityUtils.isAccessibilityMode()) {
      return;
    }
    let eventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibilityNotInterrupt',
      bundleName: 'com.ohos.settings',
      triggerAction: 'common',
      textAnnouncedForAccessibility: ResourceUtil.getStringSync(text)
    });
    accessibility.sendAccessibilityEvent(eventInfo).then(() => {
      LogUtil.debug(`${TAG} announceTextNoInterrupt success`);
    });
  }

  /**
   * 延迟播报文本
   *
   * @param text 播报内容
   * @param delay 需要延迟的时间
   */
  public static delayedAnnounceText(text: ResourceStr | undefined, delay: number): void {
    if (!text) {
      return;
    }
    setTimeout(() => {
      AccessibilityUtils.announceText(text);
    }, delay);
  }

  /**
   * 无障碍模式下Radio选中后播报"已选中",未选中播报“未选中”
   */
  public static announceRadioSelected(isSelected: boolean = true): void {
    AccessibilityUtils.announceText(isSelected ? $r('app.string.be_chosen') : $r('app.string.not_selected_click_tips'));
  }
}

export enum AccessibilityLevelType {
  /**
   * 组件可以被无障碍识别
   */
  YES = 'yes',

  /**
   * 组件不能被无障碍识别
   */
  NO = 'no',

  /**
   * 组件根据组件类型采用默认的无障碍识别策略
   */
  AUTO = 'auto',

  /**
   * 当前组件及其所有子组件不可被无障碍辅助服务所识别
   */
  NO_HIDE_DESCENDANTS = 'no-hide-descendants'
}
