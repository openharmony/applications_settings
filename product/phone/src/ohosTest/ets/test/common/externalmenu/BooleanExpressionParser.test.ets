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

import { describe, it, expect, TestType } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BooleanExpressionParser } from '@ohos/settings.common/src/main/ets/externalmenu/BooleanExpressionParser';
import { Constant } from '../../constant/Constant';

const EXPRESSION_LEGAL: string = '1 != 1';
const EXPRESSION_ILLEGAL: string = '';
const EXPRESSION_MEETCONDITIONS: string = '1 != 1';
const EXPRESSION_MISSCONDITIONS: string = '1 == 1';

export default function BooleanExpressionParserTest() {
  describe('BooleanExpressionParserTest', () => {

    /*
    * @tc.number: BooleanExpressionParserTest_001
    * @tc.name: 检验表达式合法验证
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 返回true
    */
    it('BooleanExpressionParserTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BooleanExpressionParserTest_001 start`);
      let booleanExpressionParser = new BooleanExpressionParser(EXPRESSION_LEGAL);
      let result: boolean = await booleanExpressionParser.isLegalExpression();
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} BooleanExpressionParserTest_001 end`);
    });

    /*
    * @tc.number: BooleanExpressionParserTest_002
    * @tc.name: 检验表达式不合法验证
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 返回false
    */
    it('BooleanExpressionParserTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BooleanExpressionParserTest_002 start`);
      let booleanExpressionParser = new BooleanExpressionParser(EXPRESSION_ILLEGAL);
      let result: boolean = await booleanExpressionParser.isLegalExpression();
      expect(result).assertFalse();
      LogUtil.info(`${Constant.TAG} BooleanExpressionParserTest_002 end`);
    });

    /*
    * @tc.number: BooleanExpressionParserTest_003
    * @tc.name: 表达式满足当前条件验证
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 返回true
    */
    it('BooleanExpressionParserTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BooleanExpressionParserTest_003 start`);
      let booleanExpressionParser = new BooleanExpressionParser(EXPRESSION_MEETCONDITIONS);
      let result: boolean = await booleanExpressionParser.isMeetConditions();
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} BooleanExpressionParserTest_003 end`);
    });

    /*
    * @tc.number: BooleanExpressionParserTest_004
    * @tc.name: 表达式不满足当前条件验证
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 返回false
    */
    it('BooleanExpressionParserTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BooleanExpressionParserTest_004 start`);
      let booleanExpressionParser = new BooleanExpressionParser(EXPRESSION_MISSCONDITIONS);
      let result: boolean = await booleanExpressionParser.isMeetConditions();
      expect(result).assertFalse();
      LogUtil.info(`${Constant.TAG} BooleanExpressionParserTest_004 end`);
    });
  });
}