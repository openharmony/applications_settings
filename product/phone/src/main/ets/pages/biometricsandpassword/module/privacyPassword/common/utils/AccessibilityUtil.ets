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
import { accessibility } from '@kit.AccessibilityKit';
import Log from './Log';

const TAG: string = 'AccessibilityUtil';

export default class AccessibilityUtil {
  public static autoFocusForAccessibility(componentId: string): void {
    let eventInfo: accessibility.EventInfo = ({
      type: 'requestFocusForAccessibility',
      bundleName: 'com.ohos.privactepassword',
      triggerAction: 'common',
      customId: componentId
    });
    if (componentId) {
      try {
        accessibility.sendAccessibilityEvent(eventInfo);
      } catch (error) {
        Log.error(TAG, `sendAccessibilityEvent error = { code: ${error.code}, message: ${error.message} }.`);
      }
    }
  }

  public static autoReadForAccessibility(textForAccessibility: string): void {
    let eventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.settings',
      triggerAction: 'common',
      textAnnouncedForAccessibility: textForAccessibility,
    });
    if (textForAccessibility) {
      try {
        accessibility.sendAccessibilityEvent(eventInfo);
      } catch (error) {
        Log.error(TAG, `sendAccessibilityEvent error = { code: ${error.code}, message: ${error.message} }.`);
      }
    }
  }
}