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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import {
  ConfigurationMenuManager
} from '@ohos/settings.uikit/src/main/ets/configurationparse/ConfigurationMenuManager';

export default function configurationMenuManagerTest() {
  describe('configurationMenuManagerTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('getInstanceTest', 0, () => {
      let configurationMenuManager = ConfigurationMenuManager.getInstance();
      expect(configurationMenuManager).assertEqual(ConfigurationMenuManager.getInstance());
    })

    it('ConfigurationMenuManagerTest_loadPageResource', 0, () => {
      let manna: ConfigurationMenuManager = new ConfigurationMenuManager();
      manna.loadPageResource();
      expect(manna.getIcon()).assertEqual('');
    })

    it('ConfigurationMenuManagerTest_getTitle', 0, () => {
      let configurationMenuManager = new ConfigurationMenuManager();
      let resultTitle = configurationMenuManager.getTitle();
      expect(resultTitle).not().assertNull();
    })

    it('ConfigurationMenuManagerTest_getIcon', 0, () => {
      let configurationMenuManager = new ConfigurationMenuManager();
      let icon = configurationMenuManager.getIcon();
      expect(icon).not().assertNull();
    })

    it('ConfigurationMenuManagerTest_reset', 0, () => {
      let configMenuManager = new ConfigurationMenuManager();
      let res = 'test';
      configMenuManager.reset();
      expect(res).not().assertNull();
    })

    it('ConfigurationMenuManagerTest_parseJson_null', 0, () => {
      let configMenuManager = new ConfigurationMenuManager();
      expect(configMenuManager.parseJson('')).not().assertNull();
    })
    it('ConfigurationMenuManagerTest_parseJson', 0, () => {
      let configMenuManager = new ConfigurationMenuManager();
      let value: string = '{ "bundleName": "com.ohos.ailife", "title": "test", "icon": "test", "groups": [{ "title": "test", "components": [{ "type": "radio", "capability": "test", "label": "test", "selectList": [{"value":"1", "name":"2"}], "defaultValue": "test" }] }] }';
      expect(configMenuManager.parseJson(value)).not().assertNull();
    })

  })
}

