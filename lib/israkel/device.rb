require 'cfpropertylist'
require 'sqlite3'

class Device
  attr_accessor :UUID, :type, :name, :state, :runtime

  def initialize(uuid, type, name, state, runtime)
    @UUID = uuid
    @type = type
    @name = name
    @state = state
    @runtime = runtime
  end

  def self.from_hash(hash)
    self.new(hash['UDID'], hash['deviceType'], hash['name'], hash['state'], hash['runtime'])
  end

  def self.from_plist(plist)
    self.from_hash(CFPropertyList.native_types(plist.value))
  end

  def self.with_sdk_and_type(sdk_version, type)
    Device.all.each do |device|
      return device if device.os == sdk_version && device.type.split('.').last == type
    end
    nil
  end

  def self.stop
    self.shutdown_devices
    system 'killall', '-m', '-TERM', 'iOS Simulator'
  end

  def self.shutdown_devices
    SIMCTL.booted_devices_uuids.each do |uuid|
      SIMCTL.shutdown(uuid)
    end
  end

  def self.all
    devices = []
    dirs = Dir.entries(Device.sim_root_path).reject { |entry| File.directory? entry }
    dirs.sort.each do |simulator_dir|
      plist_path = "#{Device.sim_root_path}/#{simulator_dir}/device.plist"
      if File.exists?(plist_path)
        plist = CFPropertyList::List.new(:file => plist_path)
        devices << Device.from_plist(plist)
      end
    end
    devices
  end

  def self.edit_plist(path, &block)
    if File.exists?(path)
      plist = CFPropertyList::List.new(:file => path)
      content = CFPropertyList.native_types(plist.value)
    end
    yield content || {}
    if plist
      plist.value = CFPropertyList.guess(content)
      plist.save(path, CFPropertyList::List::FORMAT_BINARY)
    end
  end

  def to_s
    "#{name} #{pretty_runtime}"
  end

  def allow_addressbook_access(bundle_id)
    allow_tcc_access('kTCCServiceAddressBook', bundle_id)
  end

  def allow_photos_access(bundle_id)
    allow_tcc_access('kTCCServicePhotos', bundle_id)
  end

  def allow_gps_access(bundle_id)
    directory = File.join(path, 'Library', 'Caches', 'locationd')
    FileUtils.mkdir_p(directory) unless Dir.exists?(directory)
    Device.edit_plist(File.join(directory, 'clients.plist')) do |content|
      set_gps_access(content, bundle_id)
    end
  end

  def set_language(language)
    edit_global_preferences do |p|
      if p['AppleLanguages']
        if p['AppleLanguages'].include?(language)
          p['AppleLanguages'].unshift(language).uniq!
        else
          fail "#{language} is not a valid language"
        end
      else
        p['AppleLanguages'] = [language]
      end
    end
  end

  def start
    system "ios-sim start --devicetypeid \"#{device_type}\""
  end

  def reset
    SIMCTL.erase @UUID
  end

  def self.sim_root_path
    File.join(ENV['HOME'], 'Library', 'Developer', 'CoreSimulator', 'Devices')
  end

  def os
    runtime.gsub('com.apple.CoreSimulator.SimRuntime.iOS-', '').gsub('-', '.')
  end

  def edit_global_preferences(&block)
    pref_path = File.join(path, 'Library', 'Preferences')
    Device.edit_plist( File.join(pref_path, '.GlobalPreferences.plist'), &block )
  end

  def edit_preferences(&block)
    pref_path = File.join(path, 'Library', 'Preferences')
    Device.edit_plist( File.join(pref_path, 'com.apple.Preferences.plist'), &block )
  end

  def tcc_path
    File.join(path, 'Library', 'TCC', 'TCC.db')
  end

  private

  def set_gps_access(hash, bundle_id)
    hash.merge!({
      bundle_id => {
        'Authorized'  => true,
        'BundleId'    => bundle_id,
        'Executable'  => "",
        'Registered'  => "",
        'Whitelisted' => false,
      }
    })
  end

  def allow_tcc_access(service, bundle_id)
    db_path = tcc_path
    db = SQLite3::Database.new(db_path)
    db.prepare "insert into access (service, client, client_type, allowed, prompt_count, csreq) values (?, ?, ?, ?, ?, ?)" do |query|
      query.execute service, bundle_id, 0, 1, 0, ""
    end
  end

  def pretty_runtime
    "iOS #{os}"
  end

  def path
    File.join(Device.sim_root_path, @UUID, 'data')
  end

  def device_type
    [@type, os].join(', ')
  end

end
