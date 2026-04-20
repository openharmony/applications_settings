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

import { describe, it, expect, MockKit, ArgumentMatchers, when } from '@ohos/hypium';
import { ResourceManagerUtil } from '@ohos/settings.common';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ExternalResourceUtils } from '@ohos/settings.systemUpdate/src/main/ets/utils/ExternalResourceUtils';

const TAG: string = 'ExternalResourceUtils';
const OUC_BUNDLE_NAME: string = 'com.ohos.ouc';

export default function externalResourceUtilsTest() {
  describe('externalResourceUtilsTest', () => {
    /*
    * @tc.number:getExternalStringByName_001
    * @tc.name: getExternalStringByName方法校验1
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: empty
    */
    it('getExternalStringByName_001', 0, async () => {
      LogUtil.info(`${TAG} getExternalStringByName_001 start`);
      let result: string = ExternalResourceUtils.getExternalStringByName(OUC_BUNDLE_NAME, '11111');
      const EXPECT_RESULT: string = '';
      expect(result).assertEqual(EXPECT_RESULT);
      LogUtil.info(`${TAG} getExternalStringByName_001 end`);
    });

    /*
    * @tc.number:getExternalStringByName_002
    * @tc.name: getExternalStringByName方法校验2
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: found
    */
    it('getExternalStringByName_002', 0, async () => {
      LogUtil.info(`${TAG} getExternalStringByName_002 start`);
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(ResourceManagerUtil,ResourceManagerUtil.getBundleResourceManager);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let result: string = ExternalResourceUtils.getExternalStringByName(OUC_BUNDLE_NAME, 'all_scene_has_new_version');
      const EXPECT_RESULT: string = '';
      expect(result).assertEqual(EXPECT_RESULT);
      LogUtil.info(`${TAG} getExternalStringByName_002 end`);
    });

    it('getExternalStringByName_003', 0, async () => {
      LogUtil.info(`${TAG} getExternalStringByName_002 start`);
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(ResourceManagerUtil,ResourceManagerUtil.getBundleResourceManager);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let result: string = ExternalResourceUtils.getExternalStringByName(OUC_BUNDLE_NAME, 'all_scene_has_new_version');
      const EXPECT_RESULT: string = '';
      expect(result).assertEqual(EXPECT_RESULT);
      LogUtil.info(`${TAG} getExternalStringByName_002 end`);
      mocker.clear(ResourceManagerUtil);
    });

    /*
    * @tc.number:getExternalPluralStringByName_001
    * @tc.name: getExternalPluralStringByName方法校验1
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: empty
    */
    it('getExternalPluralStringByName_001', 0, async () => {
      LogUtil.info(`${TAG} getExternalPluralStringByName_001 start`);
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(ResourceManagerUtil,ResourceManagerUtil.getBundleResourceManager);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let result: string = ExternalResourceUtils.getExternalPluralStringByName(OUC_BUNDLE_NAME, '11111', 1);
      const EXPECT_RESULT: string = '';
      expect(result).assertEqual(EXPECT_RESULT);
      LogUtil.info(`${TAG} getExternalPluralStringByName_001 end`);
      mocker.clear(ResourceManagerUtil);
    });

    /*
    * @tc.number:getExternalPluralStringByName_002
    * @tc.name: getExternalPluralStringByName方法校验2
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: found
    */
    it('getExternalPluralStringByName_002', 0, async () => {
      LogUtil.info(`${TAG} getExternalPluralStringByName_002 start`);
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(ResourceManagerUtil,ResourceManagerUtil.getBundleResourceManager);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let result: string =
        ExternalResourceUtils.getExternalPluralStringByName(OUC_BUNDLE_NAME, 'all_scene_device_count', 2);
      const EXPECT_RESULT: string = '';
      expect(result).assertEqual(EXPECT_RESULT);
      LogUtil.info(`${TAG} getExternalPluralStringByName_002 end`);
      mocker.clear(ResourceManagerUtil);
    });
  });
}