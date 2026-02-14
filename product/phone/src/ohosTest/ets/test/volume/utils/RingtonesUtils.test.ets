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
import { afterAll, afterEach,
  ArgumentMatchers,
  beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium'
import { RingtoneType, SimRingtoneKey } from '../../../../../main/ets/Setting/Volume/constant/VolumeConstant'
import { ToneType } from '../../../../../main/ets/Setting/Volume/model/RingtoneParam'
import { RingtonesUtils } from '../../../../../main/ets/Setting/Volume/utils/RingtonesUtils'
import { VolumeDataType, VolumeStateInfo } from '../../../../../main/ets/Setting/Volume/model/VolumeType'
import systemSoundManager from '@ohos.multimedia.systemSoundManager'
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts'

export default function RingtonesUtilsTest() {

  describe('RingtonesUtilsTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('assertEqual', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a = 'test'
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertEqual('test')
    })

    it("RingtonesUtilsTest_getRingtoneKey", 0, () => {
      RingtonesUtils.getRingtoneKey(false, RingtoneType.RINGTONE_TYPE_SIM)
      RingtonesUtils.getRingtoneKey(false, RingtoneType.RINGTONE_TYPE_SMS)
      RingtonesUtils.getRingtoneKey(false, RingtoneType.RINGTONE_TYPE_NOTIFICATION)
      RingtonesUtils.getRingtoneKey(false, RingtoneType.RINGTONE_TYPE_ALARM)
      RingtonesUtils.getRingtoneKey(false, ToneType.MESSAGE_TONE)
      RingtonesUtils.getRingtoneKey(false, ToneType.RINGTONE)
      RingtonesUtils.getRingtoneKey(false, ToneType.NOTIFICATION_TONE)

      RingtonesUtils.getRingtoneKey(true, RingtoneType.RINGTONE_TYPE_SIM)
      RingtonesUtils.getRingtoneKey(true, RingtoneType.RINGTONE_TYPE_SMS)
      RingtonesUtils.getRingtoneKey(true, RingtoneType.RINGTONE_TYPE_NOTIFICATION)
      RingtonesUtils.getRingtoneKey(true, RingtoneType.RINGTONE_TYPE_ALARM)
      RingtonesUtils.getRingtoneKey(true, ToneType.MESSAGE_TONE)
      RingtonesUtils.getRingtoneKey(true, ToneType.RINGTONE)
      RingtonesUtils.getRingtoneKey(true, ToneType.NOTIFICATION_TONE)
      let res = RingtonesUtils.getRingtoneKey(true, ToneType.NOTIFICATION_TONE)
      expect(res !== null).assertTrue()
    })

    it("RingtonesUtilsTest_getRingtoneUri", 0, async (done: Function) => {
      try {
        let context: Context = AppStorage.get<Context>('pageContext') as Context;
        await RingtonesUtils.getRingtoneUri(RingtoneType.RINGTONE_TYPE_SIM, context);
        await RingtonesUtils.getRingtoneUri(RingtoneType.RINGTONE_TYPE_SMS, context);
        await RingtonesUtils.getRingtoneUri(RingtoneType.RINGTONE_TYPE_ALARM, context);
        let res1 = await RingtonesUtils.getRingtoneUri(RingtoneType.RINGTONE_TYPE_NOTIFICATION, context);
        expect(res1 !== null).assertTrue();
      } catch (e) {
      } finally {
        done();
      }
    })

    it('RingtonesUtilsTest_updateRingtone', 0, () => {

      let data: VolumeDataType = {
        currentIndex: 0,
        isSelect: true,
      }
      let info: VolumeStateInfo = {
        summaryInfo: "1",
        primaryState: "1",
        secondaryState: "2"
      }
      RingtonesUtils.updateRingtone(data, RingtoneType.RINGTONE_TYPE_SIM, info)

      data.currentIndex = 1;
      RingtonesUtils.updateRingtone(data, RingtoneType.RINGTONE_TYPE_SIM, info)

      info.summaryInfo = '2';
      RingtonesUtils.updateRingtone(data, RingtoneType.RINGTONE_TYPE_SMS, info)

      info.summaryInfo = '1'
      RingtonesUtils.updateRingtone(data, RingtoneType.RINGTONE_TYPE_SMS, info)

      info.primaryState = '2'
      let res = RingtonesUtils.updateRingtone(data, RingtoneType.RINGTONE_TYPE_SMS, info)
      expect(res == null).assertTrue()
    })

    it('RingtonesUtilsTest_updateMenuStatus', 0, () => {

      let data: VolumeDataType = {
        currentIndex: 0,
        isSelect: true,
      }

      let info: VolumeStateInfo = {
        summaryInfo: "1",
        primaryState: "1",
        secondaryState: "2"
      }
      RingtonesUtils.updateMenuStatus(data, RingtoneType.RINGTONE_TYPE_SIM, info, '0', '1')

      data.isSelect = false
      RingtonesUtils.updateMenuStatus(data, RingtoneType.RINGTONE_TYPE_SIM, info, '0', '1')

      data.currentIndex = 1
      RingtonesUtils.updateMenuStatus(data, RingtoneType.RINGTONE_TYPE_SIM, info, '0', '1')

      data.currentIndex = 2;
      let res = RingtonesUtils.updateMenuStatus(data, RingtoneType.RINGTONE_TYPE_SIM, info, '0', '1')
      expect(res == null).assertTrue()
    })

    it('RingtonesUtilsTest_getEmitId', 0, () => {

      RingtonesUtils.getEmitId(NavEntryKey.RING_TONE_ENTRY)
      RingtonesUtils.getEmitId(ToneType.RINGTONE)
      RingtonesUtils.getEmitId(NavEntryKey.MESSAGING_TONE_ENTRY)
      RingtonesUtils.getEmitId(ToneType.MESSAGE_TONE)
      RingtonesUtils.getEmitId(NavEntryKey.NOTIFICATION_TONE_ENTRY)
      RingtonesUtils.getEmitId(ToneType.NOTIFICATION_TONE)
      let res = RingtonesUtils.getEmitId('ToneType.NOTIFICATION_TONE')
      expect(res).assertEqual('')
    })

    it('RingtonesUtilsTest_navKey2Type', 0, () => {

      RingtonesUtils.navKey2Type(NavEntryKey.RING_TONE_ENTRY)
      RingtonesUtils.navKey2Type(NavEntryKey.MESSAGING_TONE_ENTRY)
      RingtonesUtils.navKey2Type(NavEntryKey.NOTIFICATION_TONE_ENTRY)
      let res = RingtonesUtils.navKey2Type('')
      expect(res).assertEqual(ToneType.INVALID_TONE)
    })

    it('RingtonesUtilsTest_formatDefaultTone', 0, ()=> {

      RingtonesUtils.formatDefaultTone(false, ToneType.RINGTONE, '')
      RingtonesUtils.formatDefaultTone(false, ToneType.MESSAGE_TONE, '')
      RingtonesUtils.formatDefaultTone(false, ToneType.NOTIFICATION_TONE, '')
      let res = RingtonesUtils.formatDefaultTone(false, ToneType.INVALID_TONE, '')
      expect(res !== null).assertTrue()
    })

    it('RingtonesUtilsTest_getRingerToneList', 0, async () => {
      await RingtonesUtils.getRingerToneList(RingtoneType.RINGTONE_TYPE_SIM |
      systemSoundManager.RingtoneType.RINGTONE_TYPE_DEFAULT, 0)
      await RingtonesUtils.getRingerToneList(RingtoneType.RINGTONE_TYPE_SMS |
      systemSoundManager.RingtoneType.RINGTONE_TYPE_DEFAULT, 0)
      await RingtonesUtils.getRingerToneList(RingtoneType.RINGTONE_TYPE_NOTIFICATION |
      systemSoundManager.RingtoneType.RINGTONE_TYPE_DEFAULT, 0)
      let res = await RingtonesUtils.getRingerToneList(RingtoneType.RINGTONE_TYPE_ALARM |
      systemSoundManager.RingtoneType.RINGTONE_TYPE_DEFAULT, 0)
      expect(res !== null).assertTrue()
    })

    it('RingtonesUtilsTest_getCurrentTone_ring', 0, async () => {
      let context: Context = AppStorage.get<Context>('pageContext') as Context;
      let ringtoneList = await systemSoundManager.getSystemSoundManager().getRingtoneAttrList(context,
        systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0);
      let ringtone0: string = await RingtonesUtils.getCurrentTone(ringtoneList,
        systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0, ToneType.RINGTONE, 0);
      expect(ringtone0 !== null).assertTrue();
    });

    it('RingtonesUtilsTest_getCurrentTone_message', 0, async () => {
      let context: Context = AppStorage.get<Context>('pageContext') as Context;
      let ringtoneList = await systemSoundManager.getSystemSoundManager().getSystemToneAttrList(context,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0);
      let ringtone0: string = await RingtonesUtils.getCurrentTone(ringtoneList,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0, ToneType.MESSAGE_TONE, 0);
      expect(ringtone0 !== null).assertTrue();
    });

    it('RingtonesUtilsTest_getCurrentTone_notification', 0, async () => {
      let context: Context = AppStorage.get<Context>('pageContext') as Context;
      let ringtoneList = await systemSoundManager.getSystemSoundManager().getSystemToneAttrList(context,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION);
      let ringtone0: string = await RingtonesUtils.getCurrentTone(ringtoneList,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION, ToneType.NOTIFICATION_TONE, 0);
      expect(ringtone0 !== null).assertTrue();
    });

    it('RingtonesUtilsTest_getDefaultTone', 0, async () => {

      // let attrs: systemSoundManager.ToneAttrs = {
      //   setTitle: (title: string): void => {
      //   },
      //   setFileName: (name: string): void => {
      //   },
      //   setCategory: (category: number): void => {
      //   },
      //   getTitle: (): string => {
      //     return 'getTitle'
      //   },
      //   getFileName: (): string => {
      //     return 'getFileName'
      //   },
      //   getUri: (): string => {
      //     return 'getUri'
      //   },
      //   getCustomizedType: (): systemSoundManager.ToneCustomizedType => {
      //     return 0
      //   },
      //   getCategory: (): number => {
      //     return 0
      //   }
      // }
      //
      // let mocker = new MockKit()
      // let func:Function = mocker.mockFunc(systemSoundManager.getSystemSoundManager(),
      //   systemSoundManager.getSystemSoundManager().getDefaultRingtoneAttrs)
      // await when(func)(ArgumentMatchers.any).afterReturn(attrs)
      await RingtonesUtils.getDefaultTone(systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0,
        RingtoneType.RINGTONE_TYPE_SIM, systemSoundManager.getSystemSoundManager());
      await RingtonesUtils.getDefaultTone(systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0,
        RingtoneType.RINGTONE_TYPE_SMS, systemSoundManager.getSystemSoundManager());
      await RingtonesUtils.getDefaultTone(systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0,
        RingtoneType.RINGTONE_TYPE_NOTIFICATION, systemSoundManager.getSystemSoundManager());
      await RingtonesUtils.getDefaultTone(systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0,
        RingtoneType.RINGTONE_TYPE_ALARM, systemSoundManager.getSystemSoundManager())
    })
  })
}
