------- monitor_event.lua -------
-- パナソニックのドアフォン(VL-MWD700)の親機で、最新の録画データ情報を共有メモリに格納

-- ※設定：LUA_SD_EVENT=/monitor_run.lua
-- ※ファイルの書き込みはしない(最新の録画データ情報は共有メモリに格納)
-- ※検索対象は /DCIM の下の XXX_DOOR フォルダ(XXXは101~130)
-- ※録画データは YYY_ZZZZ.[JPG|MOV|TXT] (YYYはDR1~DR3,CM1~CM4, ZZZZは0001~0100)

--設定情報
rpath = "/DCIM"


--ライブラリ読み込み
local sub = require "/lua/sub"

--最新の録画データを検索
last_mod, last_dirpath, last_dirname, last_filepre = sub.searchLast(rpath)
print("last_mod = " .. last_mod)
print("dirpath = " .. last_dirpath)
print("dirname = " .. last_dirname)
print("filepre = " .. last_filepre)

--最新の録画データ情報を共有メモリに格納
if last_mod == 0 then
  print("No file.")
  fa.sharedmemory("write", 0, 1, "0")
else
  fa.sharedmemory("write", 0, 1, "1")
  fa.sharedmemory("write", 1, 8, last_dirname)
  fa.sharedmemory("write", 9, 8, last_filepre)
end
res = fa.sharedmemory("read", 0, 17, 0)
print("shmem = " .. res)
