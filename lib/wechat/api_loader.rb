module Wechat
  module ApiLoader
    
    def self.with(options)
      account = options[:account] || :default
      c = ApiLoader.config(account)

      case c.kind
      when 'Public'
        Wechat::Api::Public.new(c.appid, c.secret, c.timeout, c.skip_verify_ssl)
      when 'Program'
        Wechat::Api::Program.new(c.appid, c.secret, c.timeout, c.skip_verify_ssl)
      when 'Work'
        Wechat::Api::Work.new(c.corpid, c.corpsecret, c.agentid, c.timeout, c.skip_verify_ssl)
      else
        raise "Need create ~/.wechat.yml with wechat appid and secret or running at rails root folder so wechat can read config/wechat.yml"
      end
    end

    @configs = nil

    def self.config(account = :default)
      account = :default if account.nil?
      r = WechatConfig.valid.find_by(account: account)
      r || raise("Wechat configuration for #{account} is missing.")
    end

    def self.reload_config!
      @configs = loading_config!
    end

    private_class_method def self.loading_config!
      configs = config_from_file
      configs.merge!(config_from_db)

      configs.symbolize_keys!
      configs.each do |key, cfg|
        if cfg.is_a?(Hash)
          cfg.symbolize_keys!
        else
          raise "wrong wechat configuration format for #{key}"
        end
      end

      if defined?(::Rails)
        configs.each do |_, cfg|
          cfg[:access_token] ||= Rails.root.try(:join, 'tmp/access_token').try(:to_path)
          cfg[:jsapi_ticket] ||= Rails.root.try(:join, 'tmp/jsapi_ticket').try(:to_path)
        end
      end

      configs.each do |_, cfg|
        cfg[:timeout] ||= 20
        cfg[:have_session_class] = class_exists?('WechatSession')
        cfg[:oauth2_cookie_duration] ||= 1.hour
      end

      # create config object using raw config data
      cfg_objs = {}
      configs.each do |account, cfg|
        cfg_objs[account] = OpenStruct.new(cfg)
      end
      cfg_objs
    end

    private_class_method def self.config_from_db
      unless class_exists?('WechatConfig')
        return {}
      end

      WechatConfig.get_all_configs(Rails.env)
    end

    private_class_method def self.config_from_file
      if defined?(::Rails)
        config_file = ENV['WECHAT_CONF_FILE'] || Rails.root.join('config/wechat.yml')
        return resovle_config_file(config_file, Rails.env.to_s)
      else
        rails_config_file = ENV['WECHAT_CONF_FILE'] || File.join(Dir.getwd, 'config/wechat.yml')
        application_config_file = File.join(Dir.getwd, 'config/application.yml')
        home_config_file = File.join(Dir.home, '.wechat.yml')
        if File.exist?(rails_config_file)
          rails_env = ENV['RAILS_ENV'] || 'development'
          if File.exist?(application_config_file) && !defined?(::Figaro)
            require 'figaro'
            Figaro::Application.new(path: application_config_file, environment: rails_env).load
          end
          config = resovle_config_file(rails_config_file, rails_env)
          if config.present? && (default = config[:default])  && (default['appid'] || default['corpid'])
            puts "Using rails project #{ENV['WECHAT_CONF_FILE'] || "config/wechat.yml"} #{rails_env} setting..."
            return config
          end
        end
        if File.exist?(home_config_file)
          return resovle_config_file(home_config_file, nil)
        end
      end
    end

    private_class_method def self.resovle_config_file(config_file, env)
      if File.exist?(config_file)
        raw_data = YAML.load(ERB.new(File.read(config_file)).result)
        configs = {}
        if env
          # Process multiple accounts when env is given
          raw_data.each do |key, value|
            if key == env
              configs[:default] = value
            elsif m = /(.*?)_#{env}$/.match(key)
              configs[m[1].to_sym] = value
            end
          end
        else
          # Treat is as one account when env is omitted
          configs[:default] = raw_data
        end
        configs
      end
    end

    private_class_method def self.class_exists?(class_name)
      return Module.const_get(class_name).present?
    rescue NameError
      return false
    end
  end
end
