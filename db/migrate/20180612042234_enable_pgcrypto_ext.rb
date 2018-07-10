class EnablePgcryptoExt < ActiveRecord::Migration
  def change
    enable_extension 'pgcrypto'
  end
end
