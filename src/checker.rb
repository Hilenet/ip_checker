require_relative 'info'

class Checker
  attr_accessor :cache

  def initialize(ip, db)
    @ip = ip
    @cache = {}
    @db = db
    @query = build_query(ip)
  end

  def check()
    return nil if @query==nil
    ip_list = get_ips().sort
    ip_inc = ip_list - @cache.keys
    ip_inc = attach_mac_info(ip_inc)

    ip_dec = {}
    (@cache.keys - ip_list).each do |ip|
      ip_dec[ip] = @cache.delete ip
    end

    @cache.merge! ip_inc

    return ip_inc, ip_dec
  end

  def is_valid()
    @query!=nil
  end


  private

  # 172系は面倒なので後回し
  # 192.168.{0-255}.0/24-32
  def build_query(ip)
    return nil unless ip.is_a? String

    m = ip.match(/^(\d{1,3}?).(\d{1,3}?).(\d{1,3}?).(\d{1,3}?)\/(\d{1,2})$/)
    return nil unless m
    nodes = m[1..5].map!(&:to_i)
    return nil unless nodes[0..3].reject{|i|0<=i&&i<256}.empty?
    return nil unless nodes[0..1] == [192, 168]
    return nil unless 24<=nodes[4] && nodes[4]<32
    prefix = nodes[0..2].join(".")

    arr = Range.new(2, 2**(32-nodes[4])-1).map{|n| "#{prefix}.#{n}"}.to_a
    return "echo #{arr.join(" ")} | xargs -P256 -n1 ping -s1 -c1 -W1 2>/dev/null | grep ttl"
  end

  def get_ips()
    raw = `#{@query}`
    raw.split("\n").map{|n|n.split()[3].chop}
  end

  def attach_mac_info(ip_list)
    mtable={}
    raw = `arp -an | grep -v incomplete`
    arp_macs = raw.split("\n").map{|l|n=l.split();mtable[n[1][1..-2]]=n[3]}

    ip_table = {}
    ip_list.each do |ip|
      mac = mtable[ip]
      info = @db.search(mac)
      unless info
        info = Info.new(mac, generate_desc(ip))
        @db.update(info)
      end
      ip_table[ip] = info
    end

    return ip_table
  end

  def generate_desc(ip)
    "unknown"
  end
end

