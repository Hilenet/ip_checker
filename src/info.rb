
class Info
  attr_accessor :mac, :desc, :changed

  def initialize(mac, desc, changed=false)
    @mac = mac
    @desc = desc
    @changed = changed
  end

  def info_hash()
      {
        'desc': @desc,
        'changed': changed
      }
  end

  def full_hash()
    {
      @mac => info_hash()
    }
  end

  def self.convert_from_hash(mac, info_hash)
    return nil unless mac.is_a? String
    return nil unless info_hash.is_a? Hash

    desc = info_hash.dig("desc")
    changed = info_hash.dig("changed")
    return nil unless desc && changed!=nil

    Info.new(mac, desc, changed)
  end

end
