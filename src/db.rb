require 'fileutils'
require 'json'

# 想定規模だとmongoより生ファイルの方が早い...
class FileDB

  def initialize()
    @path = 'data/table.json'
    @bak_path = @path+'.bak'
  end

  def search(mac)
    json = get_living_json()
    return nil unless json

    Info.convert_from_hash(mac, json.dig(mac))
  end

  def update(info)
    json = get_living_json()
    json[info.mac] = info.info_hash()

    write_json(json)
  end

  def get_living_json()
    json = nil

    if File.exist? @path
      begin
        json = JSON.parse File.read @path
      rescue JSON::ParserError
      end
    end

    # 実体死んでればbakも見てみる
    if json==nil && File.exist?(@bak_path)
      begin
        json = JSON.parse File.read @bak_path
      rescue JSON::ParserError
      end
    end

    return json || {}
  end

  def write_json(json)
    # bakしてから
    if File.exist?(@path)
      FileUtils.cp @path, @bak_path
    end

    File.open @path, 'w' do |f|
      f.write(JSON.dump json)
    end

  end
end
