# DoorPhoneMonitor

パナソニック製ドアホン([VL-SWD700KL](https://panasonic.jp/door/p-db/VL-SWD700KL.html))に入れた無線LAN搭載SDカード([FlashAir](https://jp.toshiba-memory.com/product/flashair/sduwa/index_j.htm))上で動作するLuaスクリプト


### 使用方法

- [LUA_RUN_SCRIPT](https://www.flashair-developers.com/ja/documents/api/config/#LUA_RUN_SCRIPT) : "monitor_run.lua"  
※起動時に最新の録画データをチェックし、結果を共有メモリに格納
- [LUA_SD_EVENT](https://www.flashair-developers.com/ja/documents/api/config/#LUA_SD_EVENT) : "monitor_event.lua"  
※SDカードへの新たな書き込みをチェックし、Dropboxにアップロード＆IFTTTにトリガー送信
※DropboxのアプリトークンとIFTTTのトリガーURLの設定が必要


### 参考

- [FlashAir Developers](https://www.flashair-developers.com/ja/)
- [FlashAir Developers - チュートリアル - Lua機能](https://www.flashair-developers.com/ja/documents/tutorials/lua/)
- [FlashAir Developers - APIガイド - Lua機能](https://www.flashair-developers.com/ja/documents/api/lua/)
