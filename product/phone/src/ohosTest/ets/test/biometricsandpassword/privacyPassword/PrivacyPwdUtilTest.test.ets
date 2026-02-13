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
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import AccessibilityUtil
  from '../../../../../main/ets/pages/biometricsandpassword/module/privacyPassword/common/utils/AccessibilityUtil';
import {
  DeviceUtils
} from '../../../../../main/ets/pages/biometricsandpassword/module/privacyPassword/common/utils/DeviceUtils';
import deviceInfo from '@ohos.deviceInfo';
import FontScaleUtils
  from '../../../../../main/ets/pages/biometricsandpassword/module/privacyPassword/common/utils/FontScaleUtils';
import { common } from '@kit.AbilityKit';
import FormatUtil
  from '../../../../../main/ets/pages/biometricsandpassword/module/privacyPassword/common/utils/FormatUtil';
import {
  CommonConstants
} from '../../../../../main/ets/pages/biometricsandpassword/module/privacyPassword/common/constants/CommonConstants';
import {
  PasswordUtils
} from '../../../../../main/ets/pages/biometricsandpassword/module/privacyPassword/common/utils/PasswordUtils';
import {
  ResourceUtil
} from '../../../../../main/ets/pages/biometricsandpassword/module/privacyPassword/common/utils/ResourceUtil';
import {
  currentPwdType,
  getCredentials,
  getCurrentTokenAndCredId,
  hasLockerApp,
  isPinType,
  setUnableToAppLock,
  usePinProtection
} from '../../../../../main/ets/pages/biometricsandpassword/module/privacyPassword/common/PrivacyPassword';

interface fontSizeInter {
  fontSizeScale: number;
}

export default function PrivacyPwdUtilTest() {
  describe('privacyPwdUtilTestTest', () => {
    beforeAll(() => {
    })
    beforeEach(() => {
    })
    afterEach(() => {
    })
    afterAll(() => {
    })
    it('AccessibilityUtilTest_001', 0, () => {
      AccessibilityUtil.autoFocusForAccessibility('');
    });
    it('AccessibilityUtilTest_002', 0, () => {
      AccessibilityUtil.autoFocusForAccessibility('123');
    });
    it('AccessibilityUtilTest_003', 0, () => {
      AccessibilityUtil.autoReadForAccessibility('');
    });
    it('AccessibilityUtilTest_004', 0, () => {
      AccessibilityUtil.autoReadForAccessibility('123');
    });
    it('DeviceUtilsTest_001', 0, () => {
      if (deviceInfo.deviceType === 'phone') {
        expect(DeviceUtils.isPhone()).assertEqual(true);
      } else {
        expect(DeviceUtils.isPhone()).assertEqual(false);
      }
    });
    it('FontScaleUtilsTest_001', 0, () => {
      FontScaleUtils.getCurrentScale(getContext() as common.UIAbilityContext);
    });
    it('FontScaleUtilsTest_002', 0, () => {
      FontScaleUtils.isExtraLargeFontMode(getContext() as common.UIAbilityContext);
    });
    it('FontScaleUtilsTest_003', 0, () => {
      let ctx: ESObject = {
        config: ({
          fontSizeScale: 1
        } as fontSizeInter)
      }
      FontScaleUtils.getCurrentScale(ctx);
    });
    it('FontScaleUtilsTest_004', 0, () => {
      let ctx: ESObject = {
        config: ({
          fontSizeScale: 1
        } as fontSizeInter)
      }
      FontScaleUtils.isExtraLargeFontMode(ctx);
    });
    it('FontScaleUtilsTest_005', 0, () => {
      let ctx: ESObject = {
        config: ({
          fontSizeScale: 1.75
        } as fontSizeInter)
      }
      const maxScale = 3.2;
      FontScaleUtils.getSaveDistance(ctx, maxScale);
    });
    it('FontScaleUtilsTest_006', 0, () => {
      let ctx: ESObject = {
        config: ({
          fontSizeScale: 2
        } as fontSizeInter)
      }
      const maxScale = 3.2;
      FontScaleUtils.getSaveDistance(ctx, maxScale);
    });
    it('FontScaleUtilsTest_007', 0, () => {
      let ctx: ESObject = {
        config: ({
          fontSizeScale: 3.2
        } as fontSizeInter)
      }
      const maxScale = 3.2;
      FontScaleUtils.getSaveDistance(ctx, maxScale);
    });
    it('FontScaleUtilsTest_008', 0, () => {
      let ctx: ESObject = {
        config: ({
          fontSizeScale: 1
        } as fontSizeInter)
      }
      const maxScale = 3.2;
      FontScaleUtils.getSaveDistance(ctx, maxScale);
    });
    it('FormatUtilTest_001', 0, () => {
      let time = 0;
      expect(FormatUtil.getCountDownMessage(time)).assertEqual(CommonConstants.SPACE_PLACE_HOLDER_STRING);
    });
    it('FormatUtilTest_002', 0, () => {
      let time = 1000 * 60 * 60;
      FormatUtil.getCountDownMessage(time)
    });
    it('FormatUtilTest_003', 0, () => {
      let time = 1000 * 60;
      FormatUtil.getCountDownMessage(time)
    });
    it('FormatUtilTest_004', 0, () => {
      let time = 1000;
      FormatUtil.getCountDownMessage(time)
    });
    it('FormatUtilTest_005', 0, () => {
      let time = 100;
      FormatUtil.getCountDownMessage(time)
    });
    it('PasswordUtilsTest_001', 0, async () => {
      await PasswordUtils.openSession('');
      await PasswordUtils.closeSession('');
    });
    it('PasswordUtilsTest_002', 0, async () => {
      expect(PasswordUtils.isPinNumber6('')).assertEqual(false);
    });
    it('PasswordUtilsTest_003', 0, async () => {
      expect(PasswordUtils.isPinNumber6('111111')).assertEqual(true);
    });
    it('PasswordUtilsTest_004', 0, async () => {
      expect(PasswordUtils.isPinNumber6('111')).assertEqual(false);
    });
    it('PasswordUtilsTest_005', 0, async () => {
      let res = PasswordUtils.stringToUint8Array('');
      expect(true).assertEqual(res.length === 0);
    });
    it('PasswordUtilsTest_006', 0, async () => {
      let res = PasswordUtils.stringToUint8Array('123');
      expect(false).assertEqual(res.length === 0);
    });
    it('PasswordUtilsTest_007', 0, async () => {
      PasswordUtils.queryQuestionStatus();
    });
    it('PasswordUtilsTest_010', 0, async () => {
      let len = PasswordUtils.uint8ArrayToString(new Uint8Array()).length;
      expect(false).assertEqual(len === 0);
    });
    it('PasswordUtilsTest_011', 0, async () => {
      let len = PasswordUtils.uint8ArrayToString(new Uint8Array([1, 2, 3])).length;
      expect(false).assertEqual(len === 0);
    });
    it('PasswordUtilsTest_012', 0, async () => {
      let res = PasswordUtils.isWeakPasswords('123456');
      expect(res).assertEqual(true);
    });
    it('PasswordUtilsTest_013', 0, async () => {
      let res = PasswordUtils.isWeakPasswords('');
      expect(res).assertEqual(false);
    });
    it('PasswordUtilsTest_014', 0, async () => {
      let res = PasswordUtils.isWeakPasswords('111111');
      expect(res).assertEqual(true);
    });
    it('PasswordUtilsTest_015', 0, async () => {
      let res = PasswordUtils.isOnlyNumber('111111');
      expect(res).assertEqual(true);
    });
    it('PasswordUtilsTest_016', 0, async () => {
      let res = PasswordUtils.isOnlyNumber('');
      expect(res).assertEqual(false);
    });
    it('PasswordUtilsTest_017', 0, async () => {
      let res = PasswordUtils.isOnlyNumber('a123123');
      expect(res).assertEqual(false);
    });
    it('PasswordUtilsTest_018', 0, async () => {
      let res = PasswordUtils.isContainIllegalCharacter('a123123');
      expect(res).assertEqual(false);
    });
    it('PasswordUtilsTest_019', 0, async () => {
      let res = PasswordUtils.isContainIllegalCharacter('');
      expect(res).assertEqual(false);
    });
    it('PasswordUtilsTest_020', 0, async () => {
      let res = PasswordUtils.isContainIllegalCharacter('“”“”“”');
      expect(res).assertEqual(true);
    });
    it('PasswordUtilsTest_021', 0, async () => {
      let res = PasswordUtils.isIncludeAtLeastOneLetter('123123');
      expect(res).assertEqual(false);
    });
    it('PasswordUtilsTest_022', 0, async () => {
      let res = PasswordUtils.isIncludeAtLeastOneLetter('');
      expect(res).assertEqual(false);
    });
    it('PasswordUtilsTest_023', 0, async () => {
      let res = PasswordUtils.isIncludeAtLeastOneLetter('a123123');
      expect(res).assertEqual(true);
    });
    it('PasswordUtilsTest_024', 0, async () => {
      let res = PasswordUtils.isWeakPasswords('135790');
      expect(res).assertEqual(false);
    });
    it('PasswordUtilsTest_025', 0, async () => {
      let res = PasswordUtils.isWeakPasswords('124680');
      expect(res).assertEqual(false);
    });
    it('ResourceUtilTest_001', 0, async () => {
      let res = ResourceUtil.getStringSync(undefined);
      expect(res).assertEqual('');
    });
    it('ResourceUtilTest_002', 0, async () => {
      let res = ResourceUtil.getStringSync('str');
      expect(res).assertEqual('str');
    });
    it('ResourceUtilTest_003', 0, async () => {
      let res = ResourceUtil.getStringSync($r('sys.float.Body_L'));
      expect(res).assertEqual('');
    });
    it('ResourceUtilTest_004', 0, async () => {
      let res = ResourceUtil.getPluralStringSync(undefined, 1);
      expect(res).assertEqual('');
    });
    it('ResourceUtilTest_005', 0, async () => {
      let res = ResourceUtil.getPluralStringSync($r('sys.float.Body_L'), 1);
      expect(res).assertEqual('');
    });
    it('ResourceUtilTest_006', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringSync);
      when(mockFunc)().afterReturn(null);
      const result = ResourceUtil.getAnyStrFormatStringSync($r('sys.float.Body_L'), 'test');
      expect(result).assertEqual('');
    });
    it('ResourceUtilTest_007', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringSync);
      when(mockFunc)().afterReturn(null);
      const result = ResourceUtil.getAnyNumFormatStringSync($r('sys.float.Body_L'), 1);
      expect(result).assertEqual('');
    });
    it('ResourceUtilTest_008', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringSync);
      when(mockFunc)().afterReturn(null);
      const result = ResourceUtil.getAnyNumFormatStringSync($r('sys.float.Body_L'), 1);
      expect(result).assertEqual('');
    });
    it('PrivacyPassword_001', 0, () => {
      getCredentials();
    });
    it('PrivacyPassword_002', 0, () => {
      isPinType();
    });
    it('PrivacyPassword_003', 0, () => {
      currentPwdType();
    });
    it('PrivacyPassword_004', 0, () => {
      getCurrentTokenAndCredId();
    });
    it('PrivacyPassword_005', 0, () => {
      hasLockerApp();
    });
    it('PrivacyPassword_006', 0, () => {
      usePinProtection();
    });
    it('PrivacyPassword_007', 0, () => {
      setUnableToAppLock();
    });
  })
}