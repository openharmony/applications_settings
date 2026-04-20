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
import { userAuth } from '@kit.UserAuthenticationKit';
import { common } from '@kit.AbilityKit';
import Log from './utils/Log';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/* instrument ignore file */
const TAG = 'CheckScreenLock';

const DEFAULT_LENGTH = 6;

export async function checkScreenLock(
  titleStr: string,
  context: Context
) : Promise<boolean> {
  const prom = new Promise<boolean>((resolve, reject)=>{
    try {
      const rand = cryptoFramework.createRandom();
      const challengeValue = rand.generateRandomSync(DEFAULT_LENGTH).data;
      const userAuthTypeArray = [userAuth.UserAuthType.PIN];
      const authParam: userAuth.AuthParam = {
        challenge: challengeValue,
        authType: userAuthTypeArray,
        authTrustLevel: userAuth.AuthTrustLevel.ATL3,
      };
      const widgetParam: userAuth.WidgetParam = {
        title: titleStr
      };
      const userAuthInstance = userAuth.getUserAuthInstance(authParam, widgetParam);
      userAuthInstance.start();
      userAuthInstance.on('result', {
        onResult(result) {
          if (result.result === userAuth.UserAuthResultCode.SUCCESS) {
            Log.info(TAG, 'userAuthInstance callback result success');
            resolve(true);
          } else if (result.result === userAuth.UserAuthResultCode.CANCELED) {
            Log.info(TAG, 'userAuthInstance callback result cancel');
            resolve(false);
          } else {
            resolve(false);
          }
        }
      });
    } catch (err) {
      Log.error(TAG, `auth catch error, error code: ${err?.code}, error message: ${err?.message}`);
      reject(err);
    }
  })
  return prom;
}

