------- monitor_event.lua -------
-- パナソニックのドアフォン(VL-MWD700)の親機で、最新の録画データをdropboxにアップしIFTTTトリガーを発行

-- ※設定：LUA_SD_EVENT=/monitor_event.lua
-- ※ファイルの書き込みはしない(最新の録画データ情報は共有メモリに格納)
-- ※検索対象は /DCIM の下の XXX_DOOR フォルダ(XXXは101~130)
-- ※録画データは YYY_ZZZZ.[JPG|MOV|TXT] (YYYはDR1~DR3,CM1~CM4, ZZZZは0001~0100)

--設定情報
rpath = "/DCIM"
dropbox_token = "xxxxxxxxxxxxxxxxxxxxx"
ifttt_url = "https://maker.ifttt.com/trigger/xxxxxxxxxxxx/with/key/xxxxxxxxxxxxxxxxxx"


--ライブラリ読み込み
local sub = require "/lua/sub"
--sleep(6000)

--最新の録画データ情報
shm_mod = 0
last_mod = 0
last_dirpath = ""
last_dirname = ""
last_filepre = ""

--最新の録画データ情報を共有メモリから取得
res0 = fa.sharedmemory("read", 0, 1, 0)
if res0 == "1" then
  local dirname = fa.sharedmemory("read", 1, 8, 0)
  local filepre = fa.sharedmemory("read", 9, 8, 0)
  local dirpath = rpath .. "/" .. dirname
  shm_mod = lfs.attributes( dirpath .. "/" .. filepre .. ".TXT", "modification" )
end
print("shm_mod = " .. shm_mod)

--最新の録画データを検索
last_mod, last_dirpath, last_dirname, last_filepre = sub.searchLast(rpath)
print("last_mod = " .. last_mod)
print("dirpath = " .. last_dirpath)
print("dirname = " .. last_dirname)
print("filepre = " .. last_filepre)

--ファイルがなければ終了
if last_mod == 0 or last_mod <= shm_mod then
  print("No file.")
  goto EXIT
end

--dropboxへアップロード
local base_local = last_dirpath .. "/" .. last_filepre
local base_remote = sub.time2path( sub.getDatetime(last_mod) )
print("base_local = " .. base_local)
print("base_remote = " .. base_remote)
sub.dropboxUpload( dropbox_token, base_local .. ".JPG", base_remote .. ".jpg" )
sub.dropboxUpload( dropbox_token, base_local .. ".MOV", base_remote .. ".mov" )

--共有リンクを取得
local link_jpg = sub.dropboxCreateLink( dropbox_token, base_remote .. ".jpg" )
local link_mov = sub.dropboxCreateLink( dropbox_token, base_remote .. ".mov" )
print("link_jpg = " .. link_jpg)
print("link_mov = " .. link_mov)

--IFTTTにトリガーを送信
if link_jpg == nil then
  link_jpg = ""
end
if link_mov == nil then
  link_mov = ""
end
sub.sendIftttEvent(ifttt_url, link_jpg, link_mov, "test3")

--最新の録画データ情報を共有メモリに格納
fa.sharedmemory("write", 0, 1, "1")
fa.sharedmemory("write", 1, 8, last_dirname)
fa.sharedmemory("write", 9, 8, last_filepre)
res = fa.sharedmemory("read", 0, 17, 0)
print("shmem = " .. res)


::EXIT::
