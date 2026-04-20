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

/**
 * 公共事件常量定义
 */
export class CommonEventConstant {
  // 息屏公共事件
  public static readonly COMMON_EVENT_SCREEN_OFF: string = 'usual.event.SCREEN_OFF';

  public static readonly EVENT_BATTERY_QUANTITY_REFRESH: string = 'battery_quantity_refresh';
  public static readonly EVENT_BATTERY_CONSUME_LINE_CHART_MODEL_CHANGE: string = 'battery_consume_line_chart_model_change';
  public static readonly EVENT_BATTERY_CONSUME_STATE_CHANGE: string = 'battery_consume_state_change';
  public static readonly EVENT_BATTERY_CONSUME_SECOND_STATE_CHANGE: string = 'battery_consume_second_state_change';
  public static readonly EVENT_BATTERY_READ_DATA: string = 'battery_read_data';
  public static readonly EVENT_BATTERY_READ_LINEA_CHART_DATA: string = 'battery_read_linea_chart_data';
  public static readonly EVENT_BATTERY_PAGE_SHOW: string = 'battery_page_show';
  public static readonly EVENT_BATTERY_PAGE_HIDE: string = 'battery_page_hide';
  public static readonly EVENT_HALF_SCREEN_DISPLAY_SWITCH_CHANGE: string = 'half_screen_display_switch';
  public static readonly EVENT_HALF_SCREEN_DISPLAY_ENABLE_CHANGE: string = 'half_screen_display_enable';
  public static readonly EVENT_VOLUME_PAGE_HIDE: string = 'volume_page_hide';
  public static readonly EVENT_VOLUME_PAGE_SHOW: string = 'volume_page_show';
  public static readonly EVENT_VOLUME_RINGTONE_PAGE_STATE_CHANGE: string = 'volume_ringtone_page_state_change';
  public static readonly EVENT_VOLUME_AVPLAYER_PLAYING: string = 'volume_avplayer_playing';
  public static readonly EVENT_BATTERY_APP_POWER_LIST_LOADING: string = 'battery_app_power_List_loading';

  public static readonly EVENT_BLUETOOTH_CLOSE_PAIR_DIALOG: string = 'bluetooth_close_pair_dialog';
  public static readonly EVENT_WLAN_UN_SAVE_DIALOG: string = 'wlan_un_save_dialog';
  public static readonly EVENT_BLUETOOTH_STATE_CHANGE: string = 'bluetooth_state_change';
  public static readonly EVENT_BLUETOOTH_HELP_POPUP_CHANGE: string = 'bluetooth_help_popup_show_change';
  public static readonly EVENT_BLUETOOTH_CLICK_PAIR: string = 'bluetooth_click_pair';
  public static readonly EVENT_NEARLINK_CLOSE_PAIR_DIALOG: string = 'nearlink_close_pair_dialog';

  public static readonly EVENT_SETTINGS_CONTENT_PADDING: string = 'setting_content_padding';
  public static readonly EVENT_KEY_MOUSE_SWITCH_CHANGE: string = 'key_mouse_switch_change';
  public static readonly EVENT_KEY_MOUSE_DEVICE_CHANGE: string = 'key_mouse_device_change';

  public static readonly EVENT_KEY_OPEN_USER_ADDING_STATUS_DIALOG: string = 'key_open_user_adding_status_dialog';

  public static readonly EVENT_ID_QUERY_RECOVER_KEY_FOR_PWD_UPLOAD: string = 'event_id_recover_key_info_success';
}