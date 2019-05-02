class RailsWechatInit < ActiveRecord::Migration[6.0]
  def change
    
    create_table :wechat_sessions do |t|
      t.string :openid, null: false
      t.jsonb :hash_store, default: {}
      t.timestamps null: false
    end
    
    add_index :wechat_sessions, :openid, unique: true
    
    
    create_table :wechat_configs do |t|
      # config environment, typical values: production, development or test
      t.string :environment, null: false, default: 'development'
      # account name
      t.string :account, null: false
      # whether this config is activated
      t.boolean :enabled, default: true

      # public account
      t.string :appid
      t.string :secret

      # corp account
      t.string :corpid
      t.string :corpsecret
      t.integer :agentid

      # when encrypt_mode is true, encoding_aes_key must be specified
      t.boolean :encrypt_mode
      t.string :encoding_aes_key

      # app token
      t.string :token, null: false
      # path to access token storage file
      t.string :access_token, null: false
      # path to jsapi ticket storage file
      t.string :jsapi_ticket, null: false
      # set to false if RestClient::SSLCertificateNotVerified is thrown
      t.boolean :skip_verify_ssl, default: true
      t.integer :timeout, default: 20
      t.string :trusted_domain_fullname

      t.timestamps null: false
    end

    add_index :wechat_configs, [:environment, :account], unique: true, length: {environment: 20, account: 100}
    
    
    create_table :wechat_menus do |t|
      t.references :wechat_config
      t.references :parent
      t.string :type
      t.string :menu_type
      t.string :name
      t.string :value
      t.string :appid
      t.string :pagepath
      t.timestamps
    end
  end
end
