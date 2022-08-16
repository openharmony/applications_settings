/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import nfcController from '@ohos.nfc.controller';

const TAG = ConfigData.TAG + 'NfcModel: ';

export class NfcModel {
  private nfcStatus: boolean;
  private isNfcEnabled: boolean;

  /**
   * register Nfc Status change
   * @param callback
   */
  registerNfcStatusObserver(callback) {
    LogUtil.info(TAG + 'start register nfc status observer' );
    nfcController.on('nfcStateChange', (code) => {
      if(code == nfcController.NfcState.STATE_OFF || code == nfcController.NfcState.STATE_ON) {
        if (code == nfcController.NfcState.STATE_ON) {
          this.isNfcEnabled = true;
          this.nfcStatus = true;
        }
        if (code == nfcController.NfcState.STATE_OFF) {
          this.isNfcEnabled = false;
          this.nfcStatus = false;
        }
        AppStorage.SetOrCreate('isNfcEnabled', this.isNfcEnabled);
        AppStorage.SetOrCreate('nfcStatus', this.nfcStatus);
        LogUtil.info(TAG + 'nfc active status code : ' + code + " isNfcEnabled" + this.isNfcEnabled);
      }
      callback(code);
    })
    LogUtil.info(TAG + 'end register nfc status observer' );
  }

  /**
   * check whether NFC is open
   * return boolean. true is mean of NFC open, false is mean of NFC close
   */
  isNfcOpen(): boolean {
    const isOpen: boolean = nfcController.isNfcOpen();
    LogUtil.info(TAG + 'check nfc is open: ' + isOpen);
    return isOpen;
  }

  /**
   * open NFC
   * return boolean. true is mean of NFC open success, false is mean of NFC open failed
   */
  openNfc(): boolean {
    let enableNfc = nfcController.openNfc();
    LogUtil.info(TAG + 'open nfc: ' + enableNfc);
    return enableNfc;
  }

  /**
   * close NFC
   * return boolean. true is mean of NFC close success, false is mean of NFC close failed
   */
  closeNfc(): boolean {
    let disableNfc = nfcController.closeNfc();
    LogUtil.info(TAG + 'close nfc' + disableNfc);
    return disableNfc;
  }
}

let nfcModel = new NfcModel();
export default nfcModel as NfcModel;