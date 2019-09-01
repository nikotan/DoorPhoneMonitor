local cjson = require "cjson"
local sub = {}


--最新の録画データを検索
sub.searchLast = function( rpath )
  local last_mod = 0
  local last_dirpath = ""
  local last_dirname = ""
  local last_filepre = ""

  for dirname in lfs.dir(rpath) do
    dirpath = rpath .. "/" .. dirname
    mod_dir = lfs.attributes( dirpath, "mode" )
    --print(dirname .. "[" .. mod_dir .. "]")

    if mod_dir == "directory" and string.find(dirname, "^%d+_DOOR$") ~= nil then
      for filename in lfs.dir(dirpath) do
        filepath = dirpath .. "/" .. filename
        mod = lfs.attributes( filepath, "modification" )
        --print(filename .. "[" .. mod .. "]")

        --ファイル名をパース
        local t = {}
        local i = 1
        for s in string.gmatch(filename, "[^%.]+") do
          t[i] = s
          i = i + 1
        end
        --print(i .. ":" .. t[2])

        if i >= 2 and t[2] == "TXT" and mod > last_mod then
          last_mod = mod
          last_dirpath = dirpath
          last_dirname = dirname
          last_filepre = t[1]
        end
      end
    end
  end

  return last_mod, last_dirpath, last_dirname, last_filepre
end


--dropboxにファイルをアップロードする
--<https://seesaawiki.jp/flashair-dev/d/Lua%3aDropbox%a4%cb%a5%a2%a5%c3%a5%d7%a5%ed%a1%bc%a5%c9%28%a5%b7%a5%f3%a5%d7%a5%eb%c8%c7%29>
sub.dropboxUpload = function( token, path_local, path_remote )
  --ファイルサイズを取得
  len_s = lfs.attributes( path_local, "size" )
  --Dropbox引数(上書き・通知の有無)
  dropboxArg = '{"path": "'.. path_remote ..'","mode": "overwrite"}'
  --ヘッダー情報
  hed = {
    ["Content-Length"] = len_s,
    ["Authorization"] = "Bearer " .. token,
    ["Dropbox-API-Arg"] = dropboxArg,
    ["Content-Type"] = "application/octet-stream"
  }
  --リクエスト
  b,c,h = fa.request {
    url = "https://content.dropboxapi.com/2/files/upload",
    method = "POST",
    headers = hed,
    file = path_local,
    bufsize = 1460*10
  }

  if c > 200 then
    print("dropbox error[c] = " .. c)
    print("dropbox error[h] = " .. h)
    print("dropbox error[b] = " .. b)
  else
    print("dropbox OK!")
  end
end


--dropboxでファイルを共有リンクを作成する
sub.dropboxCreateLink = function( token, path_remote )
  --ボディ
  local mes = { path = path_remote }
  mes = cjson.encode(mes)
  len_s = tostring(string.len(mes))
  --ヘッダー情報
  local hed = {
    ["Content-Length"] = len_s,
    ["Authorization"] = "Bearer " .. token,
    ["Content-Type"] = "application/json"
  }
  --リクエスト
  b,c,h = fa.request {
    url = "https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings",
    method = "POST",
    headers = hed,
    body = mes
  }

  if c > 200 then
    print("dropbox error[c] = " .. c)
    print("dropbox error[h] = " .. h)
    print("dropbox error[b] = " .. b)
    return nil
  else
    print("dropbox OK!")
    local resp = cjson.decode(b)
    return resp["url"]
  end
end


--IFTTTにトリガーを送信
--<https://seesaawiki.jp/flashair-dev/d/Lua%3aIFTTT%a4%ce%a5%c8%a5%ea%a5%ac>
--<http://lynxeyed.hatenablog.com/?page=1436541407>
sub.sendIftttEvent = function( url, v1, v2, v3 )
  --ボディ
  local mes = {
    value1 = v1,
    value2 = v2,
    value3 = v3
  }
  mes = cjson.encode(mes)
  len_s = tostring(string.len(mes))
  --ヘッダー情報
  local hed = {
    ["Content-Length"] = len_s,
    ["Content-Type"] = "application/json"
  }
  --リクエスト
  b,c,h = fa.request {
    url = url,
    method = "POST",
    headers = hed,
    body = mes
  }

  if c > 200 then
    print("ifttt error[c] = " .. c)
    print("ifttt error[h] = " .. h)
    print("ifttt error[b] = " .. b)
  else
    print("ifttt OK!")
  end
end


--ファイル更新時刻を可読にする
--<https://seesaawiki.jp/flashair-dev/d/Lua%3A%A5%D5%A5%A1%A5%A4%A5%EB%B9%B9%BF%B7%C6%FC%BB%FE%A4%CE%BC%E8%C6%C0>
sub.getDatetime = function( fat_binary_time )
  local year = bit32.band (bit32.rshift(fat_binary_time, 9+16),0x7F) + 1980
  local month = bit32.band (bit32.rshift(fat_binary_time, 5+16),0x0F)
  local day = bit32.band (bit32.rshift(fat_binary_time,0+16),0x1F)

  local hour = bit32.band (bit32.rshift(fat_binary_time, 11),0x1F)
  local min = bit32.band (bit32.rshift(fat_binary_time, 5),0x3F)
  local sec = bit32.band (fat_binary_time,0x1F)*2; --FAT時間は秒数が2秒刻み

  return year, month, day, hour, min, sec
end
sub.time2path = function( year, month, day, hour, min, sec )
  return string.format("/%04d-%02d-%02d/%02d-%02d-%02d", year, month, day, hour, min, sec)
end


return sub
