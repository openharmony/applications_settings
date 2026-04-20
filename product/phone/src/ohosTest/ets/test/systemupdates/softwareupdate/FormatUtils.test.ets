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

import { describe, it, expect } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FormatUtils } from '@ohos/settings.systemUpdate/src/main/ets/utils/FormatUtils';

const TAG: string = 'FormatUtilsTest';

export default function formatUtilsTest() {
  describe('formatUtilsTest', () => {
    /*
    * @tc.number:parseJson_001
    * @tc.name: parseJson方法校验1
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: not undefined
    */
    it('parseJson_001', 0, async () => {
      LogUtil.info(`${TAG} parseJson_001 start`);
      let result: Nullable<Record<string, Object>> = FormatUtils.parseJson('{"test":"aa","isShowBadge":true}');
      expect(result?.['test']).assertEqual('aa');
      expect(result?.['isShowBadge'] as boolean).assertTrue();
      LogUtil.info(`${TAG} parseJson_001 end`);
    });

    /*
    * @tc.number:parseJson_002
    * @tc.name: parseJson方法校验2
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: undefined
    */
    it('parseJson_002', 0, async () => {
      LogUtil.info(`${TAG} parseJson_002 start`);
      let result: Nullable<Record<string, Object>> = FormatUtils.parseJson('');
      expect(result).assertEqual(undefined);
      LogUtil.info(`${TAG} parseJson_002 end`);
    });

    /*
    * @tc.number:stringify_001
    * @tc.name: stringify方法校验1
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: not undefined
    */
    it('stringify_001', 0, async () => {
      LogUtil.info(`${TAG} stringify_001 start`);
      let record: Record<string, Object> = {};
      record['test'] = 'aa';
      record['isShowBadge'] = true;
      let result: string = FormatUtils.stringify(record);
      expect(result).assertEqual('{"test":"aa","isShowBadge":true}');
      LogUtil.info(`${TAG} stringify_001 end`);
    });

    /*
    * @tc.number:stringify_002
    * @tc.name: stringify方法校验2
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: undefined
    */
    it('stringify_002', 0, async () => {
      LogUtil.info(`${TAG} stringify_002 start`);
      let result: string = FormatUtils.stringify(undefined);
      expect(result).assertEqual('');
      LogUtil.info(`${TAG} stringify_002 end`);
    });

    /*
    * @tc.number:formatStrInOrder_001
    * @tc.name: formatStrInOrder方法校验1
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: not undefined
    */
    it('formatStrInOrder_001', 0, async () => {
      LogUtil.info(`${TAG} formatStrInOrder_001 start`);
      let result: string = FormatUtils.formatStrInOrder('%1$s will install in %2$s seconds.', 'V1.0', '20');
      expect(result).assertEqual('V1.0 will install in 20 seconds.');
      LogUtil.info(`${TAG} formatStrInOrder_001 end`);
    });

    /*
    * @tc.number:formatStrInOrder_002
    * @tc.name: formatStrInOrder方法校验2
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: undefined
    */
    it('formatStrInOrder_002', 0, async () => {
      LogUtil.info(`${TAG} formatStrInOrder_002 start`);
      let result: string = FormatUtils.formatStrInOrder('');
      expect(result).assertEqual('');
      LogUtil.info(`${TAG} formatStrInOrder_002 end`);
    });
  });
}