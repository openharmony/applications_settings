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

import hiSysEvent from '@ohos.hiSysEvent';

export class HiSysEventConstants {
  public static readonly behaviorEventType = hiSysEvent.EventType.BEHAVIOR;
  public static readonly OPERATION_CHECK_PWD: string = 'check_pwd';
  public static readonly OPERATION_CHECK_PIN: string = 'check_pin';
  public static readonly OPERATION_CHECK_MIX_AND_NUM: string = 'check_mix_and_num';
  public static readonly OPERATION_CHECK_MIX_AND_NUM_NEXT: string = 'check_mix_and_num next button';
  public static readonly OPERATION_CHECK_MIX_AND_NUM_CANCEL: string = 'check_mix_and_num cancel button';
  public static readonly OPERATION_CHECK_PWD_PROTECT: string = 'check_protect';
  public static readonly OPERATION_CHECK_PWD_PROTECT_CANCEL: string = 'check_protect cancel button';
  public static readonly OPERATION_CHECK_PWD_PROTECT_NEXT: string = 'check_protect next button';
  public static readonly OPERATION_UPDATE_PWD_PIN: string = 'update_pwd_pin';
  public static readonly OPERATION_UPDATE_PWD_MIX: string = 'update_pwd mix';
  public static readonly OPERATION_UPDATE_PWD_NUM: string = 'update_pwd num';
  public static readonly OPERATION_UPDATE_WEAK_PIN_CONTINUE: string = 'update_pwd weak pin continue';
  public static readonly OPERATION_UPDATE_WEAK_PIN_RESET: string = 'update_pwd weak pin reset';
  public static readonly OPERATION_UPDATE_MIX_CANCEL: string = 'update_pwd mix cancel button';
  public static readonly OPERATION_UPDATE_MIX_CONFIRM: string = 'update_pwd mix confirm button';
  public static readonly OPERATION_UPDATE_WEAK_MIX_CONTINUE: string = 'update_pwd weak mix continue';
  public static readonly OPERATION_UPDATE_WEAK_MIX_RESET: string = 'update_pwd weak mix reset';
  public static readonly OPERATION_UPDATE_NUM_CANCEL: string = 'update_pwd num cancel button';
  public static readonly OPERATION_UPDATE_NUM_CONFIRM: string = 'update_pwd num confirm button';
  public static readonly OPERATION_UPDATE_WEAK_NUM_CONTINUE: string = 'update_pwd num pin continue';
  public static readonly OPERATION_UPDATE_WEAK_NUM_RESET: string = 'update_pwd num pin reset';
  public static readonly OPERATION_UPDATE_OTHER_TYPE: string = 'update_pwd other type pwd button';
  public static readonly OPERATION_UPDATE_PWD_PROTECT: string = 'update_protect';
  public static readonly OPERATION_UPDATE_PWD_PROTECT_NEXT: string = 'update_protect next button';
  public static readonly OPERATION_UPDATE_PWD_PROTECT_CANCEL: string = 'update_protect cancel button';
  public static readonly OPERATION_DELETE: string = 'delete_pwd';
  public static readonly OPERATION_DELETE_PWD_NEXT: string = 'delete_pwd next button';
  public static readonly PRIVATE_PIN_UPDATE: string = 'PRIVATE_PIN_UPDATE';
  public static readonly PRIVATE_PIN_DELETE: string = 'PRIVATE_PIN_DELETE';
  public static readonly USER_OPERATION: string = 'USER_OPERATION';
  public static readonly PRIVATE_PIN_ENROLL: string = 'PRIVATE_PIN_ENROLL';
  public static readonly UPDATE_PWD: number = 1;
  public static readonly UPDATE_PROTECT: number = 2;
  public static readonly USER_OPERATION_BEGIN: string = 'begin';
  public static readonly USER_OPERATION_END: string = 'end';
  public static readonly USER_OPERATION_CLICK: string = 'click';
  public static readonly USER_OPERATION_CONTEINUE: string = 'continue';
  public static readonly USER_OPERATION_CANCEL: string = 'cancel';
  public static readonly DELETE_CLOSE: number = 0;
  public static readonly USE_SCREEN_PIN_PROTECT: number = 1;
  public static readonly DELETE_SWITCH_TO_PASSWORD: string = '1';
  public static readonly DELETE_LIST: number = 1
}

